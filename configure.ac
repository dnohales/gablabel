AC_PREREQ([2.64])

# Initialization
AC_INIT([Gablabel],
        [0.1.0],
        [damiannohales@gmail.com],
        [gablabel])

AC_CONFIG_SRCDIR([src/Makefile.am])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([build-aux])

AM_INIT_AUTOMAKE
AM_MAINTAINER_MODE

# Check for programs
AC_PROG_CC
AC_PROG_CC_STDC
AM_PROG_VALAC([0.12.0])
AC_PROG_INSTALL
IT_PROG_INTLTOOL([0.35])

# i18n stuff
GETTEXT_PACKAGE=gablabel
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE, "$GETTEXT_PACKAGE", [Package name for gettext])
AM_GNU_GETTEXT_VERSION([0.17])
AM_GLIB_GNU_GETTEXT

# Packages
GLIB_REQUIRED_VERSION=2.12.0
GTK_REQUIRED_VERSION=2.18.0
WEBKIT_REQUIRED_VERSION=1.3.0

PKG_CHECK_MODULES(GABLABEL, [
	gthread-2.0 >= $GLIB_REQUIRED_VERSION
	glib-2.0 >= $GLIB_REQUIRED_VERSION
	gobject-2.0 >= $GLIB_REQUIRED_VERSION
	gmodule-2.0 >= $GLIB_REQUIRED_VERSION
	gio-2.0 >= $GLIB_REQUIRED_VERSION
	gio-unix-2.0 >= $GLIB_REQUIRED_VERSION
	gtk+-2.0 >= $GTK_REQUIRED_VERSION
	webkit-1.0 >= $WEBKIT_REQUIRED_VERSION
])
AC_SUBST(GABLABEL_CFLAGS)
AC_SUBST(GABLABEL_LIBS)

VALA_PACKAGES="--pkg webkit-1.0 --pkg gtk+-2.0 --pkg config --pkg appindicator-0.1 "
AC_SUBST(VALA_PACKAGES)

# AppIndicator stuff
APPINDICATOR_REQUIRED=0.0.7

AC_ARG_ENABLE(appindicator,
                        AS_HELP_STRING([--enable-appindicator[=@<:@no/auto/yes@:>@]],[Build support for application indicators ]),
                        [enable_appindicator=$enableval],
                        [enable_appindicator="auto"])

if test x$enable_appindicator = xauto ; then
        PKG_CHECK_EXISTS([appindicator-0.1 >= $APPINDICATOR_REQUIRED],
                         enable_appindicator="yes",
                         enable_appindicator="no")
fi

if test x$enable_appindicator = xyes ; then
        PKG_CHECK_EXISTS([appindicator-0.1 >= $APPINDICATOR_REQUIRED],,
                         AC_MSG_ERROR([appindicator-0.1 is not installed]))
        PKG_CHECK_MODULES(APP_INDICATOR,
                        appindicator-0.1 >= $APPINDICATOR_REQUIRED)
        AC_SUBST(APP_INDICATOR_CFLAGS)
        AC_SUBST(APP_INDICATOR_LIBS)
        AC_DEFINE(HAVE_APP_INDICATOR, 1, [Have AppIndicator])
fi
AM_CONDITIONAL(HAVE_APP_INDICATOR, test x"$enable_appindicator" = xyes)

AC_CONFIG_FILES([Makefile
	src/Makefile
	po/Makefile.in
	data/Makefile
	vapi/Makefile
])

AC_OUTPUT

