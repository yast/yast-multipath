# Makefile.am for multipath/src

yncludedir = @yncludedir@/multipath

client_DATA = 			\
	multipath.ycp

ynclude_DATA =			\
	complex.ycp		\
	helps.ycp		\
	options.ycp		\
	wizards.ycp

desktop_DATA =			\
	multipath.desktop

module_DATA =			\
	Multipath.ycp

# create a symlink for local build, #145327
multipath:
	ln -sf . $@
ycpchook = multipath

EXTRA_DIST = $(client_DATA) $(ynclude_DATA) $(module_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common
