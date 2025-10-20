
declare_module(MainAudio)

set(MUE_ENABLE_AUDIO_EXPORT ON)

set(MODULE_SRC
    audio.cpp
    audio.h
    audiosynth.cpp
    audiosynth.h

    ${MU_ROOT}/src/playback/internal/playbackcontroller.cpp
    ${MU_ROOT}/src/playback/internal/playbackcontroller.h
    ${MU_ROOT}/src/playback/internal/soundprofilesrepository.cpp
    ${MU_ROOT}/src/playback/internal/soundprofilesrepository.h
    ${MU_ROOT}/src/playback/internal/drumsetloader.cpp
    ${MU_ROOT}/src/playback/internal/drumsetloader.h
    ${MU_ROOT}/src/notation/utilities/percussionutilities.cpp
    ${MU_ROOT}/src/notation/utilities/percussionutilities.h
)

set(MODULE_INCLUDE
    ${MU_ROOT}/src/framework/audio
)

add_subdirectory(${MU_ROOT}/src/framework/audio          muse_audio)
add_subdirectory(${MU_ROOT}/src/importexport/audioexport audioexport)

set(MODULE_LINK
    muse_audio
    iex_audioexport
)

setup_module()
