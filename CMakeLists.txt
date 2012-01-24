project("gablabel" C)
cmake_minimum_required(VERSION 2.8)


list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)


#
# Base bits
# 
set (DATADIR_ROOT "${CMAKE_INSTALL_PREFIX}/share")
set (DATADIR "${DATADIR_ROOT}/gablabel")
set(LOCALEDIR "${DATADIR_ROOT}/locale")
set(PACKAGE_NAME "gablabel")
set(PACKAGE_VERSION "0.1")
set(PACKAGE_STRING "Gablabel ${PACKAGE_VERSION}")
set (GETTEXT_PACKAGE "gablabel")


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
install (FILES ${_datafiles} DESTINATION ${DATADIR})
#install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/gablabel.desktop DESTINATION "${CMAKE_INSTALL_PREFIX}/share/applications")


#
# i18n
# 
find_package (Gettext REQUIRED)

add_custom_command (OUTPUT ${CMAKE_SOURCE_DIR}/po/${PROJECT_NAME}.pot
        COMMAND xgettext -c --files-from ${CMAKE_SOURCE_DIR}/po/POTFILES.in --keyword=_ -o ${CMAKE_SOURCE_DIR}/po/${PROJECT_NAME}.pot --no-wrap --no-location
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )

if (${GETTEXT_FOUND} STREQUAL "TRUE")
        set (HAVE_GETTEXT true)
        file (GLOB _translations ${CMAKE_SOURCE_DIR}/po/*.po)
        GETTEXT_CREATE_TRANSLATIONS (${CMAKE_SOURCE_DIR}/po/${PROJECT_NAME}.pot
                ALL ${_translations})
endif (${GETTEXT_FOUND} STREQUAL "TRUE")


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
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/16.png" DESTINATION "${DATADIR_ROOT}/icons/hicolor/16x16/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/22.png" DESTINATION "${DATADIR_ROOT}/icons/hicolor/22x22/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/24.png" DESTINATION "${DATADIR_ROOT}/icons/hicolor/24x24/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/32.png" DESTINATION "${DATADIR_ROOT}/icons/hicolor/32x32/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/36.png" DESTINATION "${DATADIR_ROOT}/icons/hicolor/36x36/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/64.png" DESTINATION "${DATADIR_ROOT}/icons/hicolor/64x64/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/96.png" DESTINATION "${DATADIR_ROOT}/icons/hicolor/96x96/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/256.png" DESTINATION "${DATADIR_ROOT}/icons/hicolor/256x256/apps" RENAME gablabel.png)
install(FILES "${CMAKE_SOURCE_DIR}/data/icons/scalable.svg" DESTINATION "${DATADIR_ROOT}/icons/hicolor/scalable/apps" RENAME gablabel.png)

