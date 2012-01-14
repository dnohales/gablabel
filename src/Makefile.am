VALAFLAGS = \
	--vapidir ../vapi \
	--pkg config \
	$(VALA_PACKAGES)

AM_CFLAGS = \
	-DDATADIR=\"$(datadir)\" \
	-DPACKAGE_DATADIR=\""$(datadir)/gablabel"\" \
	-DPACKAGE_LOCALEDIR=\""$(datadir)/locale"\" \
	$(GABLABEL_CFLAGS) \
	-include $(CONFIG_HEADER) 
	
bin_PROGRAMS = gablabel

gablabel_SOURCES = \
	gablabel.vala

gablabel_LOADD = \
	$(GABLABEL_LIBS)
