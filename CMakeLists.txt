project("gablabel" C)
cmake_minimum_required(VERSION 2.8)

set(PACKAGE_NAME "gablabel")
set(PACKAGE_VERSION "0.1")
set(PACKAGE_STRING "Gablabel ${PACKAGE_VERSION}")
set(GETTEXT_PACKAGE "gablabel")
if(DEFINED DEVMODE)
    set(DATADIR "${CMAKE_SOURCE_DIR}/data/gablabel")
else()
    set(DATADIR "${CMAKE_INSTALL_PREFIX}/share/remmina")
endif()
set(LOCALEDIR "${CMAKE_INSTALL_PREFIX}/share/locale")

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)

include(ValaPrecompile)
include(ValaVersion)
find_package(Vala)
ensure_vala_version("0.11.0" MINIMUM)

add_subdirectory(src)
