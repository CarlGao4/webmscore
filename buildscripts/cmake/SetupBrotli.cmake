set(BROTLIDEC_FOUND TRUE)
set(BROTLIDEC_LIBRARIES brotlidec-static brotlicommon-static)
set(BROTLIDEC_INCLUDE_DIRS ${MU_ROOT}/thirdparty/brotli/c/include)
set(SKIP_INSTALL_ALL TRUE)

add_compile_definitions(FT_CONFIG_OPTION_USE_BROTLI)

subdirs(
    ${MU_ROOT}/thirdparty/brotli
)
