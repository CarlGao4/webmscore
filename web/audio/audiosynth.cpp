
#include "global/log.h"
#include "async/processevents.h"

#include "audio/worker/internal/workerplayback.h"
#include "audio/worker/internal/audioengine.h"

#include "./audiosynth.h"

using namespace muse;
using namespace muse::audio;
using namespace muse::audio::worker;

namespace MainAudio {

/**
 * De-interleave audio channels
 * @param dest: [ channelA #len frames, channelB #len frames ]
 * @param src:  [ channelA frame0, channelB frame0, channelA frame1, channelB frame1, ... ]
 */
void deInterleave(float* dest, const float* src, size_t framesLen) {
    for (size_t i = 0, j = 0; i < framesLen; i++, j+=2) {
        dest[i] = src[j];
        dest[framesLen + i] = src[j+1];
    }
}

const char* Synth::processBatch(int batchSize, bool cancel) {
    auto resArr = (SynthRes**)calloc(batchSize, sizeof(SynthRes*)); // array of pointers to SynthRes data 
    for (int i = 0; i < batchSize; i++) {
        resArr[i] = (*synthFn)(cancel);
    }
    return reinterpret_cast<const char*>(resArr);
}

Synth Synth::start(MainScore score, float starttime) {
    LOGI() << String(u"starttime %1").arg(starttime);

    // use buffer size of 512 frames
    static const size_t renderStep = 512;
    static const size_t channels = 2;
    static const size_t sampleRate = 44100;

    // Wait async ticks, otherwise `sequenceIdList` is empty
    //  previous `Playback::addSequence()` is a `Promise`
    async::processEvents();
    //  resolve `totalDuration`
    async::processEvents();

    auto playback = modularity::_ioc()->resolve<WorkerPlayback>("");
    IF_ASSERT_FAILED (playback->getSequences().size() > 0) {
        LOGE() << "no playback sequence found!";
        return nullptr;
    }
    ITrackSequencePtr sequence = playback->getSequences().at(0); // use only the first `sequence`

    // Seek
    // https://github.com/musescore/MuseScore/blob/v4.6.2/src/framework/audio/worker/internal/workerplayback.cpp#L606-L607
    sequence->player()->stop();
    sequence->player()->seek(starttime * 1000); // get ms

    // Setup audio source
    // The original code used injection to get the audio engine, but in this static function we can't do this
    // So we use the same method getting WorkerPlayback
    auto audioEngine = modularity::_ioc()->resolve<muse::audio::worker::IAudioEngine>("");

    // https://github.com/musescore/MuseScore/blob/v4.6.2/src/framework/audio/worker/internal/export/soundtrackwriter.cpp#L100-L103
    audioEngine->setMode(RenderMode::OfflineMode);
    auto source = audioEngine->mixer();
    source->setSampleRate(sampleRate);
    source->setIsActive(true);

    // https://github.com/musescore/MuseScore/blob/v4.6.2/src/framework/audio/worker/internal/export/soundtrackwriter.cpp#L68
    const auto totalDuration = sequence->player()->duration();
    const samples_t totalSamples = (totalDuration / 1000000.f) * sampleRate;
    LOGI() << String(u"totalDuration %1, totalSamples %2").arg(totalDuration).arg((int64_t)totalSamples);

    bool done = false;
    samples_t playedSamples = starttime * sampleRate;
    auto synthIterator = [done, playedSamples, totalSamples, source](bool cancel = false) mutable -> SynthRes* { // must use by-copy capture because variables are destroyed as the `_synthAudio` function ends
        if (done) {
            return new SynthRes{done, -1, -1, 0, {}};
        }

        float buffer[renderStep * channels] = {};
        auto res = (SynthRes*)calloc(1, sizeof(SynthRes) + sizeof(buffer)); 
        res->chunkSize = sizeof(buffer);

        // render audio buffer
        source->process(buffer, renderStep);
        deInterleave((float*)res->chunk, buffer, renderStep);

        auto prevPlayed = playedSamples;
        playedSamples += renderStep;
        if (playedSamples >= totalSamples || cancel) {
            // finished, do cleanup
            source->setIsActive(false);
            done = true;
        }

        res->done = done;
        res->startTime = float(prevPlayed) / sampleRate;
        res->endTime = float(playedSamples) / sampleRate;

        return res;
    };

    // persist this `synthIterator` function
    synthIterators.push_back(synthIterator);

    return Synth(&synthIterators.back());
}

} // namespace MainAudio
