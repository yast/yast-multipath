# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2006 Novell, Inc. All Rights Reserved.
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail, you may find
# current contact information at www.novell.com.
# ------------------------------------------------------------------------------

# File:	include/multipath/helps.ycp
# Package:	Configuration of multipath
# Summary:	Help texts of all the dialogs
# Authors:	Coly Li <coyli@novell.com>
#
# $Id: helps.ycp,v 1.4 2007/01/19 07:42:45 coly Exp $
module Yast
  module MultipathHelpsInclude
    def initialize_multipath_helps(include_target)
      textdomain "multipath"

      # All helps are here
      @HELPS = {
        # Read dialog help 1/2
        "read"                     => _(
          "<p><b><big>Initializing Multipath Configuration</big></b><br>\n</p>\n"
        ),
        # Write dialog help 1/2
        "write"                    => _(
          "<p><b><big>Saving Multipath Configuration</big></b><br>\n</p>\n"
        ),
        # dialog help for Status help
        "Status_help"              => _(
          "<p><b><big>Multipath Status</big></b><br>\n" +
            "\t\t\tStart or stop multipathd, check the multipath information.<br><br>\n" +
            "\n" +
            "\t\t\t<b><big>Stop/Start Multipathd</big></b><br>\n" +
            "\t\t\tClick <b>\"Use Multipath\"</b> to start multipathd. Click <b>\"Do not use Multipath\"</b> to stop multipathd.<br>\n" +
            "\t\t\tMultipath status information can still be displayed when multipathd stopped.<br><br>\n" +
            "\n" +
            "\t\t\t<b><big>Configure Multipath</big></b><br>\n" +
            "\t\t\tClick <b>Configure</b> Tab to make the multipath configurations.<br></p>\n"
        ),
        # dialog help for Configure tab
        "Configure_help"           => _(
          "<p><b><big>Configuration</big></b><br>\n" +
            "\t\t\tAll the content of /etc/multipath.conf can be configured here. There are four sections in the configuration file:\n" +
            "\t\t\t<b>multipaths</b>, <b>defaults</b>, <b>blacklist</b>, <b>blacklist_exception</b>, <b>devices.</b><br><br>\n" +
            "\t\t\t<b>Multipaths:</b> list of multipaths finest-grained settings.<br>\n" +
            "\t\t\t<b>Defaults:</b> multipath-tools default settings.<br>\n" +
            "\t\t\tClick <b>\"Configure Defaults\"</b> button to configure defaults settings.<br>\n" +
            "\t\t\t<b>Blacklist:</b> list of device names to be discard as not multipath candidates.<br>\n" +
            "\t\t\tClick <b>\"Configure Blacklist\"</b> button to configure blacklist settings.<br>\n" +
            "\t\t\t<b>Blacklist Exceptions:</b> list of device names to be excluded from blacklist.<br>\n" +
            "\t\t\tClick <b>\"Configure Blacklist Exceptions\"</b> button to configure blacklist_exceptions settings.<br>\n" +
            "\t\t\t<b>Devices:</b> list of per storage controller settings. Overrides default settings, overridden by per multipath settings.<br>\n" +
            "\t\t\tClick <b>\"Configure devices\"</b> button to configure devices settings.<br><br>\n" +
            "\t\t\tClick <b>\"Finish\"</b> button to save and update the configurations.<br><br></p>\n"
        ),
        # dialog help for defaults section configure tab 1/3
        "Defaults_help"            => _(
          "<p><b><big>Defaults Configuration</big></b><br>\n" +
            "\t\t\tGlobal default settings can be configured and cleared here.<br>\n" +
            "\t\t\tAny default setting here will take effect in all multipath configurations, unless a corresponding local setting overwrites it.<br>\n" +
            "\t\t\tIf a default setting here is cleared, multipath will take its own value as default setting.<br></p>\n"
        ),
        # dialog help for blacklist section configure tab 1/3
        "Blacklist_help"           => _(
          "<p><b><big>Blacklist Configuration</big></b><br>\n" +
            "\t\t\tDevice names listed here can be discarded as not multipath candidates.<br>\n" +
            "\t\t\tThere are three methods to identify a device name: <b>wwid</b>, <b>devnode</b>, <b>device</b>.<br><br>\n" +
            "\t\t\t<b>wwid</b>: The world wide ID identifying the device in blacklist.<br>\n" +
            "\t\t\t<b>devnode</b>: Regular expression can be used here to identify device names in udev_dir (default in directory /dev). Common device names are cciss, fd, hd, md, dm, sr, scd, st, ram, raw, loop.<br>\n" +
            "\t\t\t<b>device</b>: Used to identify a specific storage controller in blacklist. A device can be specified by vendor and product name.<br>\n" +
            "</p>"
        ),
        # dialog help for blacklist_exception section configure tab 1/3
        "Blacklist_Exception_help" => _(
          "<p><b><big>Blacklist Exceptions Configuration</big></b><br>\n" +
            "\t\t\tDevice names listed here are excluded from blacklist.<br>\n" +
            "\t\t\tThere are three methods to identify a device name: <b>wwid</b>, <b>devnode</b>, <b>device</b>.<br><br>\n" +
            "\t\t\t<b>wwid</b>: The world wide ID identifying the device excepted from blacklist.<br>\n" +
            "\t\t\t<b>devnode</b>: Regular expression can be used here to identify device names in udev_dir (default in directory /dev). Common device names are cciss, fd, hd, md, dm, sr, scd, st, ram, raw, loop.<br>\n" +
            "\t\t\t<b>device</b>: Used to identify a specific storage controller excepted from blacklist. A device can be specified by vendor and product name.<br>\n" +
            "</p>"
        ),
        # dialog help for devcies section configure tab 1/3
        "Devices_help"             => _(
          "<p><b><big>Devices Configuration</big></b><br>\n" +
            "\t\t\tPer storage controller settings are listed here, they override the default settings and are overridden by per multipath settings.<br>\n" +
            "\t\t\tEach device is identified by <b>vendor</b> and <b>product</b> name.<br></p>\n"
        )
      } 

      # EOF
    end
  end
end
