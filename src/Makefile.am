bin_PROGRAMS = gablabel

VALAFLAGS = \
	--vapidir "$(srcdir)/../vapi" \
	$(VALA_PACKAGES)

INCLUDES = \
	-DDATAROOT_DIR=\"$(datarootdir)\" \
	-DDATA_DIR=\""$(datadir)/gablabel"\" \
	-DLOCALE_DIR=\""$(localedir)"\" \
	$(GABLABEL_CFLAGS) \
	$(APP_INDICATOR_CFLAGS) \
	-include $(CONFIG_HEADER) 

gablabel_VALASOURCES = \
	gablabel.vala
	
gablabel_SOURCES = \
	$(gablabel_VALASOURCES)

gablabel_LDFLAGS = \
	$(GABLABEL_LIBS) \
	$(APP_INDICATOR_LIBS)

DISTCLEANFILES = \
	cd $(distdir) && \
	rm $(gablabel_VALASOURCES:.vala=.c) gablabel_vala.stamp
