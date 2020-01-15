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

# File:	modules/Multipath.ycp
# Package:	Configuration of multipath
# Summary:	Multipath settings, input and output functions
# Authors:	Coly Li <coyli@novell.com>
#
# $Id: Multipath.ycp,v 1.30 2007/01/19 09:38:40 coly Exp $
#
# Representation of the configuration of multipath.
# Input and output routines.
require "yast"
require "y2storage"
require "yast2/execute"

module Yast
  class MultipathClass < Module
    def main
      Yast.import "UI"
      textdomain "multipath"

      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Summary"
      Yast.import "Message"
      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Wizard"
      Yast.import "Confirm"
      Yast.import "PackageSystem"
      Yast.import "Mode"
      Yast.import "Stage"

      @config_modified = false


      # Abort function
      # return boolean return true if abort
      @AbortFunction = fun_ref(method(:Modified), "boolean ()")

      # work around a bug in compiling ybc with UI as Y2Namespace
      #  #299258
      @dummy = UI.GetDisplayInfo

      Yast.include self, "multipath/helps.rb"
      Yast.include self, "multipath/complex.rb"
    end

    # Abort function
    # @return [Boolean] return true if abort
    def Abort
      return @AbortFunction.call == true if @AbortFunction != nil
      false
    end
    def Modified
      @config_modified
    end


    def Read_Configures
      ret = false

      @config_modified = false
      @defaults_items = {}
      @devices_items = []
      @multipaths_items = []
      @blacklist_items = []
      @blacklist_exception_items = []


      # prepare for loading built-in configurations
      cmd = "/sbin/multipath"
      para = "-t"
      begin
        File.open(@builtin_multipath_conf_path, "w") do |stdout|
          Cheetah.run(cmd, para, stdout: stdout)
        end
      rescue Cheetah::ExecutionFailed => e
        if e.stderr != nil
          err_msg = _("Failed to show the currently used multipathd configuration.")
          err_msg += e.stderr
          Yast::Popup.Error(err_msg)
          return false
        end
      end

      ret = Read_MultipathConfig()
      if ret == false
        Report.Error(
          _("Cannot read multipath section in multipath configuration.")
        )
        return false
      end

      ret = Read_DefaultsConfig()
      if ret == false
        Report.Error(
          _("Cannot read defaults section in multipath configuration.")
        )
        return false
      end

      ret = Read_BlacklistConfig()
      if ret == false
        Report.Error(
          _("Cannot read blacklist section in multipath configuration.")
        )
        return false
      end

      ret = Read_BlacklistException_Config()
      if ret == false
        Report.Error(
          _(
            "Cannot read blacklist_exceptions section in multipath configuration."
          )
        )
        return false
      end

      ret = Read_DeviceConfig()
      if ret == false
        Report.Error(
          _("Cannot read devices section in multipath configuration.")
        )
        return false
      end
      true
    end

    # Read all multipath settings
    # @return true on success
    def Read
      ret = false

      # Multipath read dialog caption
      caption = _("Initializing Multipath Configuration")

      steps = 4

      sl = 100
      Builtins.sleep(sl)

      # We do not set help text here, because it was set outside
      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/3
          _("Read configurations"),
          # Progress stage 2/3
          _("Read service status"),
          # Progress stage 3/3
          _("Detect the devices")
        ],
        [
          # Progress step 1/3
          _("Reading the configurations..."),
          # Progress step 2/3
          _("Reading the service status..."),
          # Progress step 3/3
          _("Detecting the devices..."),
          # Progress finished
          _("Finished")
        ],
        ""
      )

      # BNC #418703
      # Checking and Installing packages only if needed (possible)
      required_pack_list = ["multipath-tools", "device-mapper"]
      if Mode.normal && Stage.normal
        ret = PackageSystem.CheckAndInstallPackagesInteractive(
          required_pack_list
        )
        if ret == false
          Report.Error(_("Cannot install required packages."))
          return false
        end
      else
        Yast.import "PackagesProposal"
        proposal_ID = "multipath_proposal"
        PackagesProposal.SetResolvables(
          proposal_ID,
          :package,
          required_pack_list
        )
        Builtins.y2milestone("Not checking installed packages")
      end

      ret = Read_Configures()
      return ret if ret == false

      Progress.NextStage
      Builtins.sleep(sl)

      # read multipath service status
      if Mode.normal && Stage.normal
        @service_status = SCR.Execute(path(".target.bash"), "/usr/bin/systemctl status multipathd")
        @service_status = 1 if Ops.greater_than(@service_status, 0)
      else
        @service_status = Convert.to_integer(
          SCR.Execute(
            path(".target.bash"),
            "/bin/ps -A -o comm | grep -q multipathd"
          )
        )
        @service_status = 1 if @service_status != 0
      end
      Progress.NextStep
      Builtins.sleep(sl)

      # read current settings
      Progress.NextStage
      # Error message
      Report.Error(Message.CannotReadCurrentSettings) if false
      Builtins.sleep(sl)

      # detect devices
      Progress.NextStage
      # Error message
      Report.Warning(_("Cannot detect devices.")) if false
      Builtins.sleep(sl)

      # Progress finished
      Progress.NextStage
      Builtins.sleep(sl)

      @config_modified = false
      true
    end

    # Write all multipath settings
    # @return true on success
    def Write
      # Multipath read dialog caption
      caption = _("Saving Multipath Configuration")

      steps = 2

      sl = 100
      Builtins.sleep(sl)

      return true if @config_modified == false

      # We do not set help text here, because it was set outside
      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/3
          _("Write the settings"),
          # Progress stage 2/3
          _("Restart multipathd")
        ],
        [
          # Progress step 1/2
          _("Writing the settings..."),
          # Progress step 2/2
          _("Restarting multipathd..."),
          # Progress finished
          _("Finished")
        ],
        ""
      )

      # write settings
      Progress.NextStage
      configurations = Build_Multipath_Conf()
      return false if configurations == nil
      if false == SCR.Write(path(".etc.multipath.all"), configurations)
        Report.Error(_("Can not write settings."))
        return false
      end
      SCR.Write(path(".etc.multipath"), nil)

      # restart multipathd
      Progress.NextStage

      if @service_status == 1
        if Mode.normal && Stage.normal
          if 0 !=
              SCR.Execute(
                path(".target.bash"),
                "/usr/bin/systemctl restart multipathd"
              )
            Report.Error(_("Restarting multipathd failed."))
            return false
          end
        else
          # There is no multipathd service, rely on Y2Storage to deactivate and
          # reactivate multipath (and all the associated virtual devices)
          Y2Storage::StorageManager.instance.deactivate
          Y2Storage::StorageManager.instance.activate
        end
        Builtins.sleep(sl)
      end

      # Progress finished
      Progress.NextStage
      Builtins.sleep(sl)

      true
    end
    def ReallyAbort
      !Modified() || Popup.ReallyAbort(true)
    end

    # Read settings dialog
    # @@return `abort if aborted and `next otherwise
    def ReadDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "read", ""))
      return :abort if !Confirm.MustBeRoot
      ret = Read()
      ret ? :next : :abort
    end

    # Write settings dialog
    # @@return `abort if aborted and `next otherwise
    def WriteDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "write", ""))
      ret = Write()
      ret ? :next : :abort
    end


    # Summary dialog
    # @return dialog result
    def SummaryDialog
      Builtins.y2milestone("--------- in SummaryDialog --------------------")

      @has_dumbtab = UI.HasSpecialWidget(:DumbTab)

      Wizard.SetContentsButtons(
        @caption,
        @contents,
        Ops.get_string(@HELPS, "Status_help", ""),
        Label.BackButton,
        Label.FinishButton
      )
      Wizard.HideBackButton

      ret = nil
      current_tab = :status
      interval_millisec = 50

      # Disable configure tab during installation
      if !(Mode.normal && Stage.normal)
        UI.ChangeWidget(Id(_("Configure")), :Enabled, false) if !@has_dumbtab
      end

      while true
        ret = UI.TimeoutUserInput(interval_millisec)
        interval_millisec = 5000
        break if ret == :next

        if ret == :timeout && current_tab == :status
          Update_Service_Status()
          next
        end

        if ret == :abort || ret == :cancel || ret == :back
          if ReallyAbort()
            break
          else
            next
          end
        elsif ret == _("Status")
          Wizard.SetContentsButtons(
            @caption,
            @contents,
            Ops.get_string(@HELPS, "Status_help", ""),
            Label.BackButton,
            Label.FinishButton
          )
          Wizard.HideBackButton
          UI.ChangeWidget(Id(:tabs), :CurrentItem, _("Status")) if @has_dumbtab
          UI.ReplaceWidget(Id(:tab_replace_id), @tab_status)
          Update_Service_Status()
          current_tab = :status
          next
        elsif ret == _("Configure")
          if !(Mode.normal && Stage.normal)
            Popup.Message(
              "Can't change configuration of multipath during installation"
            )
            if @has_dumbtab
              UI.ChangeWidget(Id(:tabs), :CurrentItem, _("Status"))
            end
            next
          end
          Wizard.SetContentsButtons(
            @caption,
            @contents,
            Ops.get_string(@HELPS, "Configure_help", ""),
            Label.BackButton,
            Label.FinishButton
          )
          Wizard.HideBackButton
          if @has_dumbtab
            UI.ChangeWidget(Id(:tabs), :CurrentItem, _("Configure"))
          end
          UI.ReplaceWidget(Id(:tab_replace_id), @tab_config)
          UI.ChangeWidget(
            Id(:multipaths_table_id),
            :Items,
            Build_MultipathsTable()
          )
          current_tab = :configure
          next
        elsif ret == :start_multipath
          if Modified() == true &&
              Popup.YesNo(_("Ignore your modification?")) == false
            Update_Service_Status()
            next
          end
          Start_Service()
          Read_Configures()
          next
        elsif ret == :stop_multipath
          if Modified() == true &&
              Popup.YesNo(_("Ignore your modification?")) == false
            Update_Service_Status()
            next
          end
          Stop_Service()
          Read_Configures()
          next
        elsif ret == :blacklist_config_id
          ret = Blacklist_Dialog()

          if ret == :cancel || ret == :abort
            break if ReallyAbort()
          elsif ret == :next || ret == :back
            Wizard.SetContentsButtons(
              @caption,
              @contents,
              Ops.get_string(@HELPS, "Configure_help", ""),
              Label.BackButton,
              Label.FinishButton
            )
            Wizard.HideBackButton
            UI.ReplaceWidget(Id(:contents_replace_id), @Tabs)
            if @has_dumbtab
              UI.ChangeWidget(Id(:tabs), :CurrentItem, _("Configure"))
            end
            UI.ReplaceWidget(Id(:tab_replace_id), @tab_config)
            UI.ChangeWidget(
              Id(:multipaths_table_id),
              :Items,
              Build_MultipathsTable()
            )
            next
          end
        elsif ret == :blacklist_exception_config_id
          ret = Blacklist_Exception_Dialog()

          if ret == :cancel || ret == :abort
            break if ReallyAbort()
          elsif ret == :next || ret == :back
            Wizard.SetContentsButtons(
              @caption,
              @contents,
              Ops.get_string(@HELPS, "Configure_help", ""),
              Label.BackButton,
              Label.FinishButton
            )
            Wizard.HideBackButton
            UI.ReplaceWidget(Id(:contents_replace_id), @Tabs)
            if @has_dumbtab
              UI.ChangeWidget(Id(:tabs), :CurrentItem, _("Configure"))
            end
            UI.ReplaceWidget(Id(:tab_replace_id), @tab_config)
            UI.ChangeWidget(
              Id(:multipaths_table_id),
              :Items,
              Build_MultipathsTable()
            )
            next
          end
        elsif ret == :defaults_config_id
          ret = Defaults_Dialog()
          if ret == :cancel || ret == :abort
            break if ReallyAbort()
          elsif ret == :next || ret == :back
            Wizard.SetContentsButtons(
              @caption,
              @contents,
              Ops.get_string(@HELPS, "Configure_help", ""),
              Label.BackButton,
              Label.FinishButton
            )
            Wizard.HideBackButton
            UI.ReplaceWidget(Id(:contents_replace_id), @Tabs)
            if @has_dumbtab
              UI.ChangeWidget(Id(:tabs), :CurrentItem, _("Configure"))
            end
            UI.ReplaceWidget(Id(:tab_replace_id), @tab_config)
            UI.ChangeWidget(
              Id(:multipaths_table_id),
              :Items,
              Build_MultipathsTable()
            )
            next
          end
        elsif ret == :device_config_id
          ret = Devices_Dialog()
          if ret == :cancel || ret == :abort
            break if ReallyAbort()
          elsif ret == :next || ret == :back
            Wizard.SetContentsButtons(
              @caption,
              @contents,
              Ops.get_string(@HELPS, "Configure_help", ""),
              Label.BackButton,
              Label.FinishButton
            )
            Wizard.HideBackButton
            UI.ReplaceWidget(Id(:contents_replace_id), @Tabs)
            if @has_dumbtab
              UI.ChangeWidget(Id(:tabs), :CurrentItem, _("Configure"))
            end
            UI.ReplaceWidget(Id(:tab_replace_id), @tab_config)
            UI.ChangeWidget(
              Id(:multipaths_table_id),
              :Items,
              Build_MultipathsTable()
            )
            next
          end
        elsif ret == :multipaths_del_id || ret == :multipaths_edit_id ||
            ret == :multipaths_table_id ||
            ret == :multipaths_add_id
          Multipath_Dialog(Convert.to_symbol(ret))
          next
        end
      end

      deep_copy(ret)
    end

    publish :variable => :config_modified, :type => "boolean"
    publish :variable => :AbortFunction, :type => "boolean ()"
    publish :function => :Abort, :type => "boolean ()"
    publish :function => :Read, :type => "boolean ()"
    publish :function => :Write, :type => "boolean ()"
    publish :function => :ReadDialog, :type => "symbol ()"
    publish :function => :WriteDialog, :type => "symbol ()"
    publish :function => :SummaryDialog, :type => "any ()"
  end

  Multipath = MultipathClass.new
  Multipath.main
end
