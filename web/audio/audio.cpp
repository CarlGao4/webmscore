
#include "audio/main/audiomodule.h"
#include "importexport/audioexport/audioexportmodule.h"

#include "playback/internal/playbackcontroller.h"
#include "playback/internal/playbackconfiguration.h"
#include "playback/internal/soundprofilesrepository.h"

namespace MainAudio {
using namespace mu;
using namespace muse;

void initModule() {
    // Setup audio engine
    auto aeM = new audio::AudioModule();
    aeM->registerExports();
    aeM->resolveImports();
    auto playbackController = new playback::PlaybackController();
    modularity::globalIoc()->registerExport<playback::IPlaybackController>("", playbackController);
    modularity::globalIoc()->registerExport<playback::ISoundProfilesRepository>("", new playback::SoundProfilesRepository());
    playbackController->init();
    aeM->onInit(IApplication::RunMode::ConsoleApp);

    auto audioM = new iex::audioexport::AudioExportModule();
    audioM->registerExports();
    audioM->resolveImports();
    audioM->onInit(IApplication::RunMode::ConsoleApp);
}

} // namespace MainAudio
