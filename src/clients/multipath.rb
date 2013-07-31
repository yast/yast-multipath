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

# File:	clients/multipath.ycp
# Package:	Configuration of multipath
# Summary:	Main file
# Authors:	Coly Li <coyli@novell.com>
#
# $Id: multipath.ycp,v 1.2 2007/01/12 06:43:10 coly Exp $
#
# Main file for multipath configuration. Uses all other files.
module Yast
  class MultipathClient < Client
    def main
      Yast.import "UI"

      #**
      # <h3>Configuration of multipath</h3>

      textdomain "multipath"

      # The main ()
      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("Multipath module started")

      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Summary"
      Yast.import "CommandLine"
      Yast.include self, "multipath/wizards.rb"

      @cmdline_description = {
        "id"         => "multipath",
        # Command line help text for the Xmultipath module
        "help"       => _(
          "Configuration of multipath"
        ),
        "guihandler" => fun_ref(method(:MultipathSequence), "any ()"),
        "initialize" => fun_ref(Multipath.method(:Read), "boolean ()"),
        "finish"     => fun_ref(Multipath.method(:Write), "boolean ()"),
        "actions"    => {},
        "options"    => {},
        "mappings"   => {}
      }

      # is this proposal or not?
      @propose = false
      @args = WFM.Args
      if Ops.greater_than(Builtins.size(@args), 0)
        if Ops.is_path?(WFM.Args(0)) && WFM.Args(0) == path(".propose")
          Builtins.y2milestone("Using PROPOSE mode")
          @propose = true
        end
      end

      # main ui function
      @ret = nil

      if @propose
        @ret = MultipathAutoSequence()
      else
        @ret = CommandLine.Run(@cmdline_description)
      end
      Builtins.y2debug("ret=%1", @ret)

      # Finish
      Builtins.y2milestone("Multipath module finished")
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret) 

      # EOF
    end
  end
end

Yast::MultipathClient.new.main
