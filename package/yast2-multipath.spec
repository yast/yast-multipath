#
# spec file for package yast2-multipath
#
# Copyright (c) 2013 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast2-multipath
Version:        3.1.1
Release:        0

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source0:        %{name}-%{version}.tar.bz2

Group:	        System/YaST
License:        GPL-2.0+
Requires:	yast2 yast2-python-bindings
BuildRequires:	perl-XML-Writer update-desktop-files yast2 yast2-testsuite
BuildRequires:  yast2-devtools >= 3.0.6
BuildRequires:	yast2-storage

BuildArchitectures:	noarch

Requires:       yast2-ruby-bindings >= 1.0.0

Summary: YaST2 - Multipath Configuration

%description
Multipath I/O is a fault tolerance technique whereby there is more than
one physical path between the CPU in a computer system and its mass
storage devices through the buses, controllers, switches, and bridge
devices connecting them.

You can configure your multipathed devices with this module.

%prep
%setup -n %{name}-%{version}

%build
%yast_build

%install
%yast_install


%files
%defattr(-,root,root)
%dir %{_prefix}/share/YaST2/include/multipath
%{_prefix}/share/YaST2/include/multipath/*
%{_prefix}/share/YaST2/clients/multipath.rb
%{_prefix}/share/YaST2/modules/Multipath.*
%{_prefix}/share/applications/YaST2/multipath.desktop
%{_prefix}/share/YaST2/scrconf/*.scr
%{_prefix}/lib/YaST2/servers_non_y2/*
%doc %{_prefix}/share/doc/packages/yast2-multipath
