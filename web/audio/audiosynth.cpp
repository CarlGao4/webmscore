#include "global/log.h"
#include "async/processevents.h"

#include "modularity/ioc.h"

#include "audio/common/rpc/irpcchannel.h"
#include "audio/worker/internal/audioengine.h"
#include "audio/worker/internal/workerplayback.h"

#include "notation/inotation.h"

#include "playback/iplaybackcontroller.h"

#include "./audiosynth.h"

using namespace muse;

namespace MainAudio {

std::vector<std::function<Synth::SynthRes*(bool)>> Synth::synthIterators;

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

    auto rpcChannel = modularity::globalIoc()->resolve<audio::rpc::IRpcChannel>("");

    // Wait async ticks, otherwise `sequenceIdList` is empty
    //  previous `Playback::addSequence()` is a `Promise`
    for (int i=0; i < 3; i++) {
        async::processEvents();
        rpcChannel->process();
    }
    //  resolve `totalDuration`
    async::processEvents();

    auto playbackController = modularity::globalIoc()->resolve<playback::IPlaybackController>("");
    auto worker_playback = modularity::globalIoc()->resolve<audio::worker::WorkerPlayback>("");
    auto audio_engine = modularity::globalIoc()->resolve<audio::worker::IAudioEngine>("");

    const auto sequenceId = playbackController->currentTrackSequenceId();
    IF_ASSERT_FAILED(sequenceId != -1) {
        LOGE() << "no playback sequence found!";
        return nullptr;
    }
    auto sequence = worker_playback->sequence(sequenceId);

    // Seek
    // https://github.com/LibreScore/webmscore/blob/v4.0/src/framework/audio/internal/worker/audiooutputhandler.cpp#L200-L201
    sequence->player()->stop();
    sequence->player()->seek_ms(starttime * 1000 * 1000); // get microsecs

    // Setup audio source
    // https://github.com/LibreScore/webmscore/blob/v4.0/src/framework/audio/internal/soundtracks/soundtrackwriter.cpp#L73-L76
    audio_engine->setMode(audio::RenderMode::OfflineMode);
    auto source = audio_engine->mixer();
    source->setSampleRate(sampleRate);
    source->setIsActive(true);

    // https://github.com/LibreScore/webmscore/blob/v4.0/src/framework/audio/internal/soundtracks/soundtrackwriter.cpp#L49
    const auto totalDuration = sequence->player()->duration();
    const audio::samples_t totalSamples = (totalDuration / 1000000.f) * sampleRate;
    LOGI() << String(u"totalDuration %1, totalSamples %2").arg(totalDuration).arg((int64_t)totalSamples);

    bool done = false;
    audio::samples_t playedSamples = starttime * sampleRate;
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
