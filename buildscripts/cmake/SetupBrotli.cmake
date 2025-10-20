set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libraries" FORCE)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to Release as none was specified.")
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build." FORCE)
else()
  message(STATUS "Build type is '${CMAKE_BUILD_TYPE}'")
endif()

set(BROTLI_SOURCE_DIR ${MU_ROOT}/thirdparty/brotli)

# Reads macro from .h file; it is expected to be a single-line define.
function(read_macro PATH MACRO OUTPUT)
  file(STRINGS ${PATH} _line REGEX "^#define +${MACRO} +(.+)$")
  string(REGEX REPLACE "^#define +${MACRO} +(.+)$" "\\1" _val "${_line}")
  set(${OUTPUT} ${_val} PARENT_SCOPE)
endfunction(read_macro)

# Version information
read_macro("${BROTLI_SOURCE_DIR}/c/common/version.h" "BROTLI_VERSION_MAJOR" BROTLI_VERSION_MAJOR)
read_macro("${BROTLI_SOURCE_DIR}/c/common/version.h" "BROTLI_VERSION_MINOR" BROTLI_VERSION_MINOR)
read_macro("${BROTLI_SOURCE_DIR}/c/common/version.h" "BROTLI_VERSION_PATCH" BROTLI_VERSION_PATCH)
set(BROTLI_VERSION "${BROTLI_VERSION_MAJOR}.${BROTLI_VERSION_MINOR}.${BROTLI_VERSION_PATCH}")
mark_as_advanced(BROTLI_VERSION BROTLI_VERSION_MAJOR BROTLI_VERSION_MINOR BROTLI_VERSION_PATCH)

# ABI Version information
read_macro("${BROTLI_SOURCE_DIR}/c/common/version.h" "BROTLI_ABI_CURRENT" BROTLI_ABI_CURRENT)
read_macro("${BROTLI_SOURCE_DIR}/c/common/version.h" "BROTLI_ABI_REVISION" BROTLI_ABI_REVISION)
read_macro("${BROTLI_SOURCE_DIR}/c/common/version.h" "BROTLI_ABI_AGE" BROTLI_ABI_AGE)
math(EXPR BROTLI_ABI_COMPATIBILITY "${BROTLI_ABI_CURRENT} - ${BROTLI_ABI_AGE}")
mark_as_advanced(BROTLI_ABI_CURRENT BROTLI_ABI_REVISION BROTLI_ABI_AGE BROTLI_ABI_COMPATIBILITY)

include(CheckFunctionExists)
set(LIBM_LIBRARY)
CHECK_FUNCTION_EXISTS(log2 LOG2_RES)
if(NOT LOG2_RES)
  set(orig_req_libs "${CMAKE_REQUIRED_LIBRARIES}")
  set(CMAKE_REQUIRED_LIBRARIES "${CMAKE_REQUIRED_LIBRARIES};m")
  CHECK_FUNCTION_EXISTS(log2 LOG2_LIBM_RES)
  if(LOG2_LIBM_RES)
    set(LIBM_LIBRARY "m")
    add_definitions(-DBROTLI_HAVE_LOG2=1)
  else()
    add_definitions(-DBROTLI_HAVE_LOG2=0)
  endif()

  set(CMAKE_REQUIRED_LIBRARIES "${orig_req_libs}")
  unset(LOG2_LIBM_RES)
  unset(orig_req_libs)
else()
  add_definitions(-DBROTLI_HAVE_LOG2=1)
endif()
unset(LOG2_RES)

set(BROTLI_INCLUDE_DIRS "${BROTLI_SOURCE_DIR}/c/include")
mark_as_advanced(BROTLI_INCLUDE_DIRS)

# set(BROTLI_LIBRARIES_CORE brotlienc brotlidec brotlicommon)
# set(BROTLI_LIBRARIES ${BROTLI_LIBRARIES_CORE} ${LIBM_LIBRARY})
# mark_as_advanced(BROTLI_LIBRARIES)

file(GLOB_RECURSE BROTLI_DEC_SOURCES RELATIVE ${BROTLI_SOURCE_DIR} c/dec/*.c)
add_library(brotlidec ${BROTLI_DEC_SOURCES})

include_directories(${BROTLI_INCLUDE_DIRS})
