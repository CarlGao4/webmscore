
declare_module(MainAudio)

set(MUE_BUILD_IMPEXP_BB_MODULE ON)
set(MUE_BUILD_IMPEXP_BWW_MODULE ON)
set(MUE_BUILD_IMPEXP_CAPELLA_MODULE ON)
set(MUE_BUILD_IMPEXP_MIDI_MODULE ON)
set(MUE_BUILD_IMPEXP_MUSEDATA_MODULE ON)
set(MUE_BUILD_IMPEXP_MUSICXML_MODULE ON)
set(MUE_BUILD_IMPEXP_OVE_MODULE ON)
set(MUE_BUILD_IMPEXP_AUDIOEXPORT_MODULE ON)
set(MUE_BUILD_IMPEXP_IMAGESEXPORT_MODULE ON)
set(MUE_BUILD_IMPEXP_GUITARPRO_MODULE ON)
set(MUE_BUILD_IMPEXP_MEI_MODULE ON)
set(MUE_BUILD_IMPEXP_VIDEOEXPORT_MODULE OFF)
set(MUE_BUILD_IMPEXP_TABLEDIT_MODULE ON)

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
)

set(MODULE_INCLUDE
    ${MU_ROOT}/src/framework/audio
)

add_subdirectory(${MU_ROOT}/src/framework/audio          audio)
add_subdirectory(${MU_ROOT}/src/importexport/audioexport audioexport)

set(MODULE_LINK
    muse_audio
    iex_audioexport
)

setup_module()
