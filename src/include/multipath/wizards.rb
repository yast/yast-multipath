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

# File:	include/multipath/wizards.ycp
# Package:	Configuration of multipath
# Summary:	Wizards definitions
# Authors:	Coly Li <coyli@novell.com>
#
# $Id: wizards.ycp,v 1.1.1.1 2006/12/09 05:26:20 coly Exp $
module Yast
  module MultipathWizardsInclude
    def initialize_multipath_wizards(include_target)
      Yast.import "UI"

      textdomain "multipath"

      Yast.import "Label"
      Yast.import "Sequencer"
      Yast.import "Wizard"
      Yast.import "Multipath"
    end

    # Whole configuration of multipath
    # @return sequence result
    def MultipathSequence
      aliases = {
        "read"  => [lambda { Multipath.ReadDialog }, true],
        "main"  => [lambda { Multipath.SummaryDialog }, true],
        "write" => [lambda { Multipath.WriteDialog }, true]
      }

      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :next => "main" },
        "main"     => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }

      Wizard.CreateDialog

      ret = Sequencer.Run(aliases, sequence)

      UI.CloseDialog
      deep_copy(ret)
    end

    # Whole configuration of multipath but without reading and writing.
    # For use with autoinstallation.
    # @return sequence result
    def MultipathAutoSequence
      # Initialization dialog caption
      caption = _("Multipath Configuration")
      # Initialization dialog contents
      contents = Label(_("Initializing..."))

      Wizard.CreateDialog
      Wizard.SetContentsButtons(
        caption,
        contents,
        "",
        Label.BackButton,
        Label.NextButton
      )

      ret = Multipath.SummaryDialog

      UI.CloseDialog
      deep_copy(ret)
    end
  end
end
