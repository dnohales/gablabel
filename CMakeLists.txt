project("gablabel" C)
cmake_minimum_required(VERSION 2.8)


list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)


#
# Application information
# 
set(PACKAGE_NAME ${PROJECT_NAME})
set(PACKAGE_VERSION_MAJOR "0")
set(PACKAGE_VERSION_MINOR "1")
set(PACKAGE_VERSION_PATCH "1")
set(PACKAGE_VERSION "${PACKAGE_VERSION_MAJOR}.${PACKAGE_VERSION_MINOR}.${PACKAGE_VERSION_PATCH}")
set(PACKAGE_STRING "Gablabel ${PACKAGE_VERSION}")
set (GETTEXT_PACKAGE ${PROJECT_NAME})
#
# Directories
# 
set (DATADIR_ROOT "${CMAKE_INSTALL_PREFIX}/share")
set (DATADIR "${DATADIR_ROOT}/gablabel")
set(LOCALEDIR "${DATADIR_ROOT}/locale")


add_custom_target (uninstall "${CMAKE_COMMAND}" -P
  "${CMAKE_SOURCE_DIR}/cmake/uninstall.cmake")


#
# config.h
# 
configure_file (${CMAKE_SOURCE_DIR}/config.h.in ${CMAKE_BINARY_DIR}/config.h)
add_definitions(-include config.h)


#
# Data
# 
file (GLOB _datafiles "${CMAKE_CURRENT_SOURCE_DIR}/data/gablabel/*")
install (FILES ${_datafiles} DESTINATION "share/gablabel")


#
# i18n
# 
find_package (Gettext REQUIRED)

file (GLOB _translations ${CMAKE_SOURCE_DIR}/po/*.po)
GETTEXT_CREATE_TRANSLATIONS (${CMAKE_SOURCE_DIR}/po/${PROJECT_NAME}.pot ALL ${_translations})

#
# Install internationalized desktop file
# 
install(CODE "execute_process(COMMAND intltool-merge -d po \"${CMAKE_SOURCE_DIR}/data/gablabel.desktop.in\" \"${CMAKE_BINARY_DIR}/gablabel.desktop\" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_QUIET)")
install(CODE "message (STATUS \"Generating translated gablabel.desktop\")")
install(FILES ${CMAKE_BINARY_DIR}/gablabel.desktop DESTINATION "share/applications")


#
# Source Code
# 
find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED gobject-2.0 glib-2.0 gio-2.0 gtk+-2.0 webkit-1.0 appindicator-0.1 gee-1.0 x11 gdk-x11-2.0)

add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.11.0" MINIMUM)

set(VALA_SRC
	src/Application.vala
	src/MainWindow.vala
	src/StatusIconManager.vala
	src/TranslatorWebView.vala
	src/KeyBindingManager.vala
	src/PreferencesDialogManager.vala
)
include(ValaPrecompile)
vala_precompile(VALA_C
	${VALA_SRC}
PACKAGES 
	config
	gee-1.0
	gdk-x11-2.0
	x11
	webkit-1.0
	gtk+-2.0
	appindicator-0.1
OPTIONS
	--vapidir "${CMAKE_SOURCE_DIR}/vapi"
)

add_executable(gablabel ${VALA_C})
target_link_libraries(gablabel -lm)
target_link_libraries(gablabel ${LIBS})

install(TARGETS gablabel RUNTIME DESTINATION bin)

#
# GSettings Schema
# 
include(GSettings)
add_schema("data/es.nohal.Gablabel.gschema.xml")

#
# Icons
# 
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/16.png" DESTINATION "share/icons/hicolor/16x16/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/22.png" DESTINATION "share/icons/hicolor/22x22/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/24.png" DESTINATION "share/icons/hicolor/24x24/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/32.png" DESTINATION "share/icons/hicolor/32x32/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/36.png" DESTINATION "share/icons/hicolor/36x36/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/64.png" DESTINATION "share/icons/hicolor/64x64/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/96.png" DESTINATION "share/icons/hicolor/96x96/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/256.png" DESTINATION "share/icons/hicolor/256x256/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/scalable.svg" DESTINATION "share/icons/hicolor/scalable/apps" RENAME gablabel.svg)

#
# Packaging
# 
SET(CPACK_GENERATOR "DEB")
SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Damián Nohales")
SET(CPACK_PACKAGE_VERSION_MAJOR ${PACKAGE_VERSION_MAJOR})
SET(CPACK_PACKAGE_VERSION_MINOR ${PACKAGE_VERSION_MINOR})
SET(CPACK_PACKAGE_VERSION_PATCH ${PACKAGE_VERSION_PATCH})
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Gablabel text translator\n Gablabel is a simplified and improved interface for Google Translator that's allows you to translate text into many languages.")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/COPYING")
SET(CPACK_DEBIAN_PACKAGE_SECTION "utils")
SET(CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://github.com/eagleoneraptor/gablabel")
SET(CPACK_DEBIAN_PACKAGE_DEPENDS "libglib2.0-0 (>= 2.24.0), libgtk2.0-0 (>= 2.20.0), libgee2 (>= 0.6.0), libx11-6, libwebkitgtk-1.0-0, libappindicator1")
 
INCLUDE(CPack)
