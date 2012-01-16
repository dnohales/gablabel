set(VALA_SRC
	gablabel.vala
)

find_package(PkgConfig)
pkg_check_modules(GOBJECT REQUIRED gobject-2.0)
pkg_check_modules(GIO REQUIRED gio-2.0)
pkg_check_modules(GTK REQUIRED gtk+-2.0)
pkg_check_modules(WEBKIT REQUIRED webkit-1.0)
pkg_check_modules(APPINDICATOR REQUIRED appindicator-0.1)

set(CFLAGS
	${GOBJECT_CFLAGS} ${GOBJECT_CFLAGS_OTHER}
	${GIO_CFLAGS} ${GIO_CFLAGS_OTHER}
	${GTK_CFLAGS} ${GTK_CFLAGS_OTHER}
	${WEBKIT_CFLAGS} ${WEBKIT_CFLAGS_OTHER}
	${APPINDICATOR_CFLAGS} ${APPINDICATOR_CFLAGS_OTHER}
)
add_definitions(${CFLAGS})

set(LIBS
	${GOBJECT_LIBRARIES}
	${GIO_LIBRARIES}
	${GTK_LIBRARIES}
	${WEBKIT_LIBRARIES}
	${APPINDICATOR_LIBRARIES}
)

set(LIB_PATHS
	${GOBJECT_LIBRARY_DIRS}
	${GIO_LIBRARY_DIRS}
	${GTK_LIBRARY_DIRS}
	${WEBKIT_LIBRARY_DIRS}
	${APPINDICATOR_LIBRARY_DIRS}
)
link_directories(${LIB_PATHS})

# Vala segfaults if its output dirs are not existant. Therefore make sure they
# are there.
macro(make_compile_directory directory)
	if (NOT IS_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${directory}")
		make_directory("${CMAKE_CURRENT_BINARY_DIR}/${directory}")
	endif (NOT IS_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${directory}")
endmacro(make_compile_directory)

vala_precompile(VALA_C
	${VALA_SRC}
PACKAGES 
	config
	webkit-1.0
	gtk+-2.0
	appindicator-0.1
OPTIONS
	--vapidir "${CMAKE_SOURCE_DIR}/vapi"
)

include_directories(${CMAKE_BINARY_DIR})

add_executable(gablabel
  	${VALA_C}
)

# explicitly add libraries (needed e.g. for Fedora 13+)
target_link_libraries(gablabel -lm)
target_link_libraries(gablabel ${LIBS})

configure_file("${CMAKE_SOURCE_DIR}/config.h.in" "${CMAKE_BINARY_DIR}/config.h")
