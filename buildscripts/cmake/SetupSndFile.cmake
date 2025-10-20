include(GetPlatformInfo)

if (OS_IS_WIN AND (NOT MINGW))
    find_path(SNDFILE_INCDIR sndfile.h PATHS ${DEPENDENCIES_INC};)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".lib")
    find_library(SNDFILE_LIB NAMES sndfile libsndfile-1 PATHS ${DEPENDENCIES_LIB_DIR} NO_DEFAULT_PATH)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".dll")
    find_library(SNDFILE_DLL NAMES sndfile libsndfile-1 PATHS ${DEPENDENCIES_LIB_DIR} NO_DEFAULT_PATH)
    message(STATUS "Found sndfile DLL: ${SNDFILE_DLL}")

elseif (OS_IS_WASM)
    set(LIBSND_PATH "" CACHE PATH "Path to libsnd sources")
    set(LIBOGG_PATH "" CACHE PATH "Path to libogg sources")
    set(LIBVORBIS_PATH "" CACHE PATH "Path to libvorbis sources")
    set(SNDFILE_INCDIR ${LIBSND_PATH}/include)

    declare_thirdparty_module(sndfile)

    list(APPEND CMAKE_MODULE_PATH ${LIBSND_PATH}/cmake)
    include(SndFileChecks)
    configure_file(${LIBSND_PATH}/src/config.h.cmake ${LIBSND_PATH}/src/config.h)

    include(CheckIncludeFiles)
    # Configure config_type.h
    check_include_files(inttypes.h INCLUDE_INTTYPES_H)
    check_include_files(stdint.h INCLUDE_STDINT_H)
    check_include_files(sys/types.h INCLUDE_SYS_TYPES_H)

    list(APPEND CMAKE_MODULE_PATH "${LIBOGG_PATH}/cmake")
    set(SIZE16 int16_t)
    set(USIZE16 uint16_t)
    set(SIZE32 int32_t)
    set(USIZE32 uint32_t)
    set(SIZE64 int64_t)
    set(USIZE64 uint64_t)

    include(CheckSizes)
    configure_file(${LIBOGG_PATH}/include/ogg/config_types.h.in ${LIBOGG_PATH}/include/ogg/config_types.h @ONLY)

    set(MODULE_SRC
        ${LIBSND_PATH}/src/sndfile.c
        ${LIBSND_PATH}/include/sndfile.hh
        ${LIBSND_PATH}/src/command.c
        ${LIBSND_PATH}/src/common.c
        ${LIBSND_PATH}/src/common.h
        ${LIBSND_PATH}/src/au.c
        ${LIBSND_PATH}/src/caf.c
        ${LIBSND_PATH}/src/file_io.c
        ${LIBSND_PATH}/src/ogg.c
        ${LIBSND_PATH}/src/ogg_vorbis.c

        ${LIBSND_PATH}/src/pcm.c
        ${LIBSND_PATH}/src/ulaw.c
        ${LIBSND_PATH}/src/alaw.c
        ${LIBSND_PATH}/src/float32.c
        ${LIBSND_PATH}/src/double64.c
        ${LIBSND_PATH}/src/ima_adpcm.c
        ${LIBSND_PATH}/src/ms_adpcm.c
        ${LIBSND_PATH}/src/gsm610.c
        ${LIBSND_PATH}/src/dwvw.c
        ${LIBSND_PATH}/src/vox_adpcm.c
        ${LIBSND_PATH}/src/interleave.c
        ${LIBSND_PATH}/src/strings.c
        ${LIBSND_PATH}/src/dither.c
        ${LIBSND_PATH}/src/cart.c
        ${LIBSND_PATH}/src/broadcast.c
        ${LIBSND_PATH}/src/audio_detect.c
        ${LIBSND_PATH}/src/ima_oki_adpcm.c
        ${LIBSND_PATH}/src/ima_oki_adpcm.h
        ${LIBSND_PATH}/src/alac.c
        ${LIBSND_PATH}/src/chunk.c
        ${LIBSND_PATH}/src/chanmap.h
        ${LIBSND_PATH}/src/chanmap.c
        ${LIBSND_PATH}/src/id3.h
        ${LIBSND_PATH}/src/id3.c
        ${LIBSND_PATH}/src/aiff.c
        ${LIBSND_PATH}/src/avr.c
        ${LIBSND_PATH}/src/dwd.c
        ${LIBSND_PATH}/src/flac.c
        ${LIBSND_PATH}/src/g72x.c
        ${LIBSND_PATH}/src/htk.c
        ${LIBSND_PATH}/src/ircam.c
        ${LIBSND_PATH}/src/macos.c
        ${LIBSND_PATH}/src/mat4.c
        ${LIBSND_PATH}/src/mat5.c
        ${LIBSND_PATH}/src/nist.c
        ${LIBSND_PATH}/src/paf.c
        ${LIBSND_PATH}/src/pvf.c
        ${LIBSND_PATH}/src/raw.c
        ${LIBSND_PATH}/src/rx2.c
        ${LIBSND_PATH}/src/sd2.c
        ${LIBSND_PATH}/src/sds.c
        ${LIBSND_PATH}/src/svx.c
        ${LIBSND_PATH}/src/txw.c
        ${LIBSND_PATH}/src/voc.c
        ${LIBSND_PATH}/src/wve.c
        ${LIBSND_PATH}/src/w64.c
        ${LIBSND_PATH}/src/wavlike.h
        ${LIBSND_PATH}/src/wavlike.c
        ${LIBSND_PATH}/src/wav.c
        ${LIBSND_PATH}/src/xi.c
        ${LIBSND_PATH}/src/mpc2k.c
        ${LIBSND_PATH}/src/rf64.c
        ${LIBSND_PATH}/src/ogg_speex.c
        ${LIBSND_PATH}/src/ogg_pcm.c
        ${LIBSND_PATH}/src/ogg_opus.c
        ${LIBSND_PATH}/src/ogg_vcomment.h
        ${LIBSND_PATH}/src/ogg_vcomment.c
        ${LIBSND_PATH}/src/nms_adpcm.c
        ${LIBSND_PATH}/src/mpeg.c
        ${LIBSND_PATH}/src/mpeg_decode.c
        ${LIBSND_PATH}/src/mpeg_l3_encode.c
        ${LIBSND_PATH}/src/GSM610/config.h
        ${LIBSND_PATH}/src/GSM610/gsm.h
        ${LIBSND_PATH}/src/GSM610/gsm610_priv.h
        ${LIBSND_PATH}/src/GSM610/add.c
        ${LIBSND_PATH}/src/GSM610/code.c
        ${LIBSND_PATH}/src/GSM610/decode.c
        ${LIBSND_PATH}/src/GSM610/gsm_create.c
        ${LIBSND_PATH}/src/GSM610/gsm_decode.c
        ${LIBSND_PATH}/src/GSM610/gsm_destroy.c
        ${LIBSND_PATH}/src/GSM610/gsm_encode.c
        ${LIBSND_PATH}/src/GSM610/gsm_option.c
        ${LIBSND_PATH}/src/GSM610/long_term.c
        ${LIBSND_PATH}/src/GSM610/lpc.c
        ${LIBSND_PATH}/src/GSM610/preprocess.c
        ${LIBSND_PATH}/src/GSM610/rpe.c
        ${LIBSND_PATH}/src/GSM610/short_term.c
        ${LIBSND_PATH}/src/GSM610/table.c
        ${LIBSND_PATH}/src/G72x/g72x.h
        ${LIBSND_PATH}/src/G72x/g72x_priv.h
        ${LIBSND_PATH}/src/G72x/g721.c
        ${LIBSND_PATH}/src/G72x/g723_16.c
        ${LIBSND_PATH}/src/G72x/g723_24.c
        ${LIBSND_PATH}/src/G72x/g723_40.c
        ${LIBSND_PATH}/src/G72x/g72x.c
        ${LIBSND_PATH}/src/ALAC/ALACAudioTypes.h
        ${LIBSND_PATH}/src/ALAC/ALACBitUtilities.h
        ${LIBSND_PATH}/src/ALAC/EndianPortable.h
        ${LIBSND_PATH}/src/ALAC/aglib.h
        ${LIBSND_PATH}/src/ALAC/dplib.h
        ${LIBSND_PATH}/src/ALAC/matrixlib.h
        ${LIBSND_PATH}/src/ALAC/alac_codec.h
        ${LIBSND_PATH}/src/ALAC/shift.h
        ${LIBSND_PATH}/src/ALAC/ALACBitUtilities.c
        ${LIBSND_PATH}/src/ALAC/ag_dec.c
        ${LIBSND_PATH}/src/ALAC/ag_enc.c
        ${LIBSND_PATH}/src/ALAC/dp_dec.c
        ${LIBSND_PATH}/src/ALAC/dp_enc.c
        ${LIBSND_PATH}/src/ALAC/matrix_dec.c
        ${LIBSND_PATH}/src/ALAC/matrix_enc.c
        ${LIBSND_PATH}/src/ALAC/alac_decoder.c
        ${LIBSND_PATH}/src/ALAC/alac_encoder.c

        #ogg
        ${LIBOGG_PATH}/include/ogg/ogg.h
        ${LIBOGG_PATH}/include/ogg/os_types.h
        ${LIBOGG_PATH}/src/bitwise.c
        ${LIBOGG_PATH}/src/framing.c

        #vorbis
        ${LIBVORBIS_PATH}/lib/vorbisenc.c
        ${LIBVORBIS_PATH}/lib/info.c
        ${LIBVORBIS_PATH}/lib/analysis.c
        ${LIBVORBIS_PATH}/lib/bitrate.c
        ${LIBVORBIS_PATH}/lib/block.c
        ${LIBVORBIS_PATH}/lib/codebook.c
        ${LIBVORBIS_PATH}/lib/envelope.c
        ${LIBVORBIS_PATH}/lib/floor0.c
        ${LIBVORBIS_PATH}/lib/floor1.c
        ${LIBVORBIS_PATH}/lib/lookup.c
        ${LIBVORBIS_PATH}/lib/lpc.c
        ${LIBVORBIS_PATH}/lib/lsp.c
        ${LIBVORBIS_PATH}/lib/mapping0.c
        ${LIBVORBIS_PATH}/lib/mdct.c
        ${LIBVORBIS_PATH}/lib/psy.c
        ${LIBVORBIS_PATH}/lib/registry.c
        ${LIBVORBIS_PATH}/lib/res0.c
        ${LIBVORBIS_PATH}/lib/sharedbook.c
        ${LIBVORBIS_PATH}/lib/smallft.c
        ${LIBVORBIS_PATH}/lib/vorbisfile.c
        ${LIBVORBIS_PATH}/lib/window.c
        ${LIBVORBIS_PATH}/lib/synthesis.c
        )

    set(MODULE_INCLUDE
        ${LIBSND_PATH}/src
        ${LIBSND_PATH}/include
        ${LIBOGG_PATH}/include
        ${LIBVORBIS_PATH}/include
        ${LIBVORBIS_PATH}/lib
        )

    setup_module()

else()
    find_package(SndFile)

    if (SNDFILE_FOUND)
        set(SNDFILE_LIB ${SNDFILE_LIBRARY})
        set(SNDFILE_INCDIR ${SNDFILE_INCLUDE_DIR})
    else()
        # Use pkg-config to get hints about paths
        find_package(PkgConfig)
        if(PKG_CONFIG_FOUND)
            pkg_check_modules(LIBSNDFILE_PKGCONF sndfile>=1.0.25 QUIET)
        endif()

        # Include dir
        find_path(LIBSNDFILE_INCLUDE_DIR
            NAMES sndfile.h
            PATHS ${LIBSNDFILE_PKGCONF_INCLUDEDIR}
            NO_DEFAULT_PATH
        )

        # Library
        find_library(LIBSNDFILE_LIBRARY
            NAMES sndfile libsndfile-1
            PATHS ${LIBSNDFILE_PKGCONF_LIBDIR}
            NO_DEFAULT_PATH
        )

        if (LIBSNDFILE_LIBRARY)
            set(SNDFILE_LIB ${LIBSNDFILE_LIBRARY})
            set(SNDFILE_INCDIR ${LIBSNDFILE_INCLUDE_DIR})
        endif()
    endif()
endif()

if (SNDFILE_INCDIR)
    message(STATUS "Found sndfile: ${SNDFILE_LIB} ${SNDFILE_INCDIR}")
else ()
    message(FATAL_ERROR "Could not find: sndfile")
endif ()
