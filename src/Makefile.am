bin_PROGRAMS = gablabel

VALAFLAGS = \
	--vapidir "$(srcdir)/../vapi" \
	--pkg config \
	$(VALA_PACKAGES)

INCLUDES = \
	-DDATADIR=\"$(datadir)\" \
	-DPACKAGE_DATADIR=\""$(datadir)/gablabel"\" \
	-DPACKAGE_LOCALEDIR=\""$(datadir)/locale"\" \
	$(GABLABEL_CFLAGS) \
	-include $(CONFIG_HEADER) 

gablabel_VALASOURCES = \
	gablabel.vala
	
gablabel_SOURCES = \
	$(gablabel_VALASOURCES)

gablabel_LDFLAGS = \
	$(GABLABEL_LIBS)

DISTCLEANFILES = \
	cd $(distdir) && \
	rm $(gablabel_VALASOURCES:.vala=.c) gablabel_vala.stamp
