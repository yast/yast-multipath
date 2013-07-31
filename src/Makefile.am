# Sources for multipath

module_DATA = \
  modules/Multipath.rb

client_DATA = \
  clients/multipath.rb

yncludedir = @yncludedir@/multipath
ynclude_DATA = \
  include/multipath/wizards.rb \
  include/multipath/options.rb \
  include/multipath/complex.rb \
  include/multipath/helps.rb

scrconf_DATA = \
  scrconf/etc_multipath.scr \
  scrconf/multipath.scr

agent_SCRIPTS = \
  servers_non_y2/ag_multipath

desktop_DATA = \
  desktop/multipath.desktop

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(scrconf_DATA) $(agent_SCRIPTS) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common