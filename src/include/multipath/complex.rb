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

# File:	modules/complex.ycp
# Package:	Configuration of multipath
# Summary:	Complex stuffs for multipath yast module
# Authors:	Coly Li <coyli@novell.com>
#
# Compelx stuffs for multipath yast module, this file is included
# by Multipath.ycp.

require "yast"
require "y2storage"
require "securerandom"

module Yast
  module MultipathComplexInclude
    def initialize_multipath_complex(include_target)
      Yast.import "UI"

      textdomain "multipath"

      Yast.import "Service"
      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "Mode"
      Yast.import "Multipath"
      Yast.import "Stage"

      Yast.include include_target, "multipath/helps.rb"

      @service_status = 0
      @has_dumbtab = false
      @device_template = "vendor %1; product %2"

      r = SecureRandom.hex
      @builtin_multipath_conf_path = "/tmp/.yast2-multipath-builtin-conf-" + r[0,8]

      Yast.include include_target, "multipath/options.rb"

      # Multipath summary dialog caption
      @caption = _("Multipath Configuration")



      @start_stop_check = RadioButtonGroup(
        Id(:start_stop_radiobutton),
        Left(
          HVSquash(
            VBox(
              Left(
                RadioButton(
                  Id(:stop_multipath),
                  Opt(:notify),
                  _("Do &not use Multipath"),
                  false
                )
              ),
              Left(
                RadioButton(
                  Id(:start_multipath),
                  Opt(:notify),
                  _("&Use Multipath"),
                  false
                )
              )
            )
          )
        )
      )


      @blacklist_items = []

      @blacklist_config = VBox(
        Id(:blacklist_config_id),
        Frame(
          _("Blacklist"),
          VBox(
            Table(
              Id(:blacklist_table_id),
              Opt(:notify),
              Header(_("Item"), _("Value")),
              Build_BlacklistTable()
            ),
            Left(
              HBox(
                PushButton(Id(:blacklist_add_id), Label.AddButton),
                PushButton(Id(:blacklist_edit_id), Label.EditButton),
                PushButton(Id(:blacklist_del_id), Label.DeleteButton)
              )
            )
          )
        )
      )


      @blacklist_exception_items = []

      @blacklist_exception_config = VBox(
        Id(:blacklist_config_id),
        Frame(
          _("Blacklist Exceptions"),
          VBox(
            Table(
              Id(:blacklist_table_id),
              Opt(:notify),
              Header(_("Item"), _("Value")),
              Build_BlacklistException_Table()
            ),
            Left(
              HBox(
                PushButton(Id(:blacklist_add_id), Label.AddButton),
                PushButton(Id(:blacklist_edit_id), Label.EditButton),
                PushButton(Id(:blacklist_del_id), Label.DeleteButton)
              )
            )
          )
        )
      )


      # will be initiated in Read_Defaults..
      @defaults_items = {}

      @defaults_config = VBox(
        Id(:defaults_config_id),
        Frame(
          _("Defaults"),
          VBox(
            Table(
              Id(:defaults_table_id),
              Opt(:notify),
              Header(_("Item"), _("Value")),
              Build_DefaultsTable()
            ),
            Left(
              HBox(
                PushButton(Id(:defaults_edit_id), Label.EditButton),
                PushButton(Id(:defaults_del_id), Label.DeleteButton)
              )
            )
          )
        )
      )

      @devices_items = []

      @devices_config = VBox(
        Id(:devices_config_id),
        Frame(
          _("Devices"),
          VBox(
            Table(
              Id(:devices_table_id),
              Opt(:notify),
              Header(_("vendor"), _("product")),
              Build_DevicesTable()
            ),
            Left(
              HBox(
                PushButton(Id(:devices_add_id), Label.AddButton),
                PushButton(Id(:devices_edit_id), Label.EditButton),
                PushButton(Id(:devices_del_id), Label.DeleteButton)
              )
            )
          )
        )
      )


      @multipaths_items = []


      @multipaths_config = Frame(
        _("Multipaths"),
        VBox(
          MinHeight(
            8,
            Table(
              Id(:multipaths_table_id),
              Opt(:notify),
              Header(_("alias"), _("wwid")),
              Build_MultipathsTable()
            )
          ),
          Left(
            HBox(
              PushButton(Id(:multipaths_add_id), Label.AddButton),
              PushButton(Id(:multipaths_edit_id), Label.EditButton),
              PushButton(Id(:multipaths_del_id), Label.DeleteButton)
            )
          )
        )
      )

      @tab_config = VBox(
        Id(:tab_config_id),
        Top(@multipaths_config),
        VBox(
          HVCenter(PushButton(Id(:defaults_config_id), _("Configure Defaults"))),
          HVCenter(PushButton(Id(:device_config_id), _("Configure Devices"))),
          HVCenter(
            PushButton(Id(:blacklist_config_id), _("Configure Blacklist"))
          ),
          HVCenter(
            PushButton(
              Id(:blacklist_exception_config_id),
              _("Configure Blacklist Exceptions")
            )
          )
        )
      )

      @tab_status_summary = RichText(
        Id(:status_summary_id),
        Opt(:plainText),
        "Status summary"
      )

      @tab_status = VBox(
        Id(:tab_status_id),
        @start_stop_check,
        @tab_status_summary
      )


      @tab_terms = [
        term(:term, Id(_("Status")), _("Status")),
        term(:term, Id(_("Configure")), _("Configure"))
      ]


      @Tabs = UI.HasSpecialWidget(:DumbTab) ?
        DumbTab(
          Id(:tabs),
          [_("Status"), _("Configure")],
          ReplacePoint(Id(:tab_replace_id), @tab_status)
        ) :
        DumbTabs(@tab_terms, ReplacePoint(Id(:tab_replace_id), @tab_status))
      @contents = HBox(
        Id(:contents_id),
        HSpacing(3.5),
        ReplacePoint(Id(:contents_replace_id), VBox(@Tabs, VSpacing(1.2)))
      )
    end

    #    build black list table from blacklist_items
    def Build_BlacklistTable
      id = 0
      table_items = Builtins.maplist(@blacklist_items) do |e|
        id = Ops.add(id, 1)
        if Ops.get_string(e, "type", "") == "device"
          sub_e = Ops.get_map(e, "value", {})
          if sub_e != {}
            product_str = Ops.get_string(sub_e, "product", "NA")
            vendor_str = Ops.get_string(sub_e, "vendor", "NA")
            value = Builtins.sformat(@device_template, vendor_str, product_str)
            next Item(Id(id), Ops.get_string(e, "name", "NA"), value)
          end
        elsif Ops.get_string(e, "type", "") == "node"
          next Item(
            Id(id),
            Ops.get_string(e, "name", "NA"),
            Ops.get_string(e, "value", "NA")
          )
        end
      end
      deep_copy(table_items)
    end

    #    build black list exception table from blacklist_exception_items
    def Build_BlacklistException_Table
      id = 0
      table_items = Builtins.maplist(@blacklist_exception_items) do |e|
        id = Ops.add(id, 1)
        if Ops.get_string(e, "type", "") == "device"
          sub_e = Ops.get_map(e, "value", {})
          if sub_e != {}
            product_str = Ops.get_string(sub_e, "product", "NA")
            vendor_str = Ops.get_string(sub_e, "vendor", "NA")
            value = Builtins.sformat(@device_template, vendor_str, product_str)
            next Item(Id(id), Ops.get_string(e, "name", "NA"), value)
          end
        elsif Ops.get_string(e, "type", "") == "node"
          next Item(
            Id(id),
            Ops.get_string(e, "name", "NA"),
            Ops.get_string(e, "value", "NA")
          )
        end
      end
      deep_copy(table_items)
    end

    #    build defaults table from defaults_items
    def Build_DefaultsTable
      table_items = []
      Builtins.foreach(@defaults_items) do |k, v|
        next if k == "NA"
        id = Builtins.symbolof(Builtins.toterm(k))
        table_items = Builtins.add(table_items, Item(Id(id), k, v))
      end
      deep_copy(table_items)
    end

    #     build devices table from devices_items
    def Build_DevicesTable
      i = 0
      table_items = Builtins.maplist(@devices_items) do |e|
        item = Item(
          Id(i),
          Ops.get_string(e, "vendor", "NA"),
          Ops.get_string(e, "product", "NA")
        )
        i = Ops.add(i, 1)
        deep_copy(item)
      end
      deep_copy(table_items)
    end

    #     build multipaths table from multipaths_items
    def Build_MultipathsTable
      i = 0
      table_items = Builtins.maplist(@multipaths_items) do |e|
        item = Item(
          Id(i),
          Ops.get_string(e, "alias", ""),
          Ops.get_string(e, "wwid", "NA")
        )
        i = Ops.add(i, 1)
        deep_copy(item)
      end
      deep_copy(table_items)
    end

    #     build a fake DumbTab by button in Ncurses, for Ncurses does not support
    #     DumbTab now.
    def DumbTabs(items, contents)
      items = deep_copy(items)
      contents = deep_copy(contents)
      tabs = HBox()
      Builtins.foreach(items) do |item|
        text = Ops.get_string(item, 1, "")
        idTerm = Ops.get_term(item, 0) { Id(:unknown) }
        tabs = Builtins.add(tabs, PushButton(idTerm, text))
      end
      tabs = Builtins.add(tabs, HStretch())
      VBox(tabs, Frame("", contents))
    end

    #     Read multipaths section from configuration file, store in multipaths_items
    def Read_MultipathConfig
      id = 0
      builtin_multipaths_items = []
      multipaths_all = Convert.to_map(
        SCR.Read(path(".etc.multipath.all.multipaths"))
      )
      if multipaths_all != nil && multipaths_all != {}
        if Ops.get_string(multipaths_all, "kind", "") == "section" &&
            Ops.get_string(multipaths_all, "name", "") == "multipaths"
          if Ops.get(multipaths_all, "value") != nil &&
              Ops.get_list(multipaths_all, "value", []) != []
            Builtins.foreach(Ops.get_list(multipaths_all, "value", [])) do |sub_section|
              item = {}
              if Ops.get_string(sub_section, "kind", "") != "section" ||
                  Ops.get_string(sub_section, "name", "") != "multipath"
                next
              end
              value = Ops.get_list(sub_section, "value", [])
              next if value == []
              Builtins.foreach(value) do |e|
                next if Ops.get_string(e, "kind", "") != "value"
                if Ops.get_string(e, "name", "") == "" ||
                    Ops.get_string(e, "value", "") == ""
                  next
                end
                name = rm_quotes(Ops.get_string(e, "name", "NA"))
                value2 = rm_quotes(Ops.get_string(e, "value", "NA"))
                Ops.set(item, name, value2)
              end
              next if Ops.get(item, "wwid", "") == ""
              Ops.set(item, "id", Builtins.tostring(id))
              id = Ops.add(id, 1)
              @multipaths_items = Builtins.add(@multipaths_items, item)
            end
          end
        end
      end

      # load built-in configuration, which are not in /etc/multipath.conf
      SCR.RegisterAgent(
        path(".content"),
        term(
          :ag_ini,
          term(
            :IniAgent,
            @builtin_multipath_conf_path,
            {
              "options"   => ["global_values", "repeat_names"],
              "comments"  => ["^[ \t]*#.*$", "^[ \t]*$"],
              "params"    => [
                {
                  "match" => [
                    "^[ \t]*([^ \t]+)[ \t]+([^ \t]+([ \t]*[^ \t]+)*)[ \t]*$",
                    "%s %s"
                  ]
                }
              ],
              "sections"  => [
                {
                  "begin" => ["[ \t]*([^ \t]+)*[ \t]*\\{[ \t]*$", "%s {"],
                  "end"   => ["^[ \t]*\\}[ \t]*$", "}"]
                }
              ],
              "subindent" => "\t"
            }
          )
        )
      )
      multipaths_all = Convert.to_map(SCR.Read(path(".content.all.multipaths")))
      SCR.UnregisterAgent(path(".content"))

      if multipaths_all != nil && multipaths_all != {}
        if Ops.get_string(multipaths_all, "kind", "") == "section" &&
            Ops.get_string(multipaths_all, "name", "") == "multipaths"
          if Ops.get(multipaths_all, "value") != nil &&
              Ops.get_list(multipaths_all, "value", []) != []
            Builtins.foreach(Ops.get_list(multipaths_all, "value", [])) do |sub_section|
              item = {}
              if Ops.get_string(sub_section, "kind", "") != "section" ||
                  Ops.get_string(sub_section, "name", "") != "multipath"
                next
              end
              value = Ops.get_list(sub_section, "value", [])
              next if value == []
              Builtins.foreach(value) do |e|
                next if Ops.get_string(e, "kind", "") != "value"
                if Ops.get_string(e, "name", "") == "" ||
                    Ops.get_string(e, "value", "") == ""
                  next
                end
                name = rm_quotes(Ops.get_string(e, "name", "NA"))
                value2 = rm_quotes(Ops.get_string(e, "value", "NA"))
                Ops.set(item, name, value2)
              end
              next if Ops.get(item, "wwid", "") == ""
              filter_ret = Builtins.filter(@multipaths_items) do |filter_e|
                if Ops.get(item, "wwid", "") ==
                    Ops.get_string(filter_e, "wwid", "NA")
                  next true
                else
                  next false
                end
              end
              next if filter_ret != nil && filter_ret != []
              Ops.set(item, "id", Builtins.tostring(id))
              id = Ops.add(id, 1)
              @multipaths_items = Builtins.add(@multipaths_items, item)
            end
          end
        end
      end

      true
    end

    #     read defaults section from configuration file, store in defaults_items
    def Read_DefaultsConfig
      value = []
      defaults_all = {}

      # initiate defaults_items
      Builtins.foreach(@defaults_section_items) do |item|
        name = Builtins.tostring(item)
        name = Builtins.substring(name, 1)
        Ops.set(@defaults_items, name, "")
      end

      # union builtin configurations and /etc/multipath.conf into one
      SCR.RegisterAgent(
        path(".content"),
        term(
          :ag_ini,
          term(
            :IniAgent,
            @builtin_multipath_conf_path,
            {
              "options"   => ["global_values", "repeat_names"],
              "comments"  => ["^[ \t]*#.*$", "^[ \t]*$"],
              "params"    => [
                {
                  "match" => [
                    "^[ \t]*([^ \t]+)[ \t]+([^ \t]+([ \t]*[^ \t]+)*)[ \t]*$",
                    "%s %s"
                  ]
                }
              ],
              "sections"  => [
                {
                  "begin" => ["[ \t]*([^ \t]+)*[ \t]*\\{[ \t]*$", "%s {"],
                  "end"   => ["^[ \t]*\\}[ \t]*$", "}"]
                }
              ],
              "subindent" => "\t"
            }
          )
        )
      )
      defaults_all = Convert.to_map(SCR.Read(path(".content.all.defaults")))
      SCR.UnregisterAgent(path(".content"))

      if defaults_all != nil && defaults_all != {}
        if defaults_all != nil &&
            Ops.get_string(defaults_all, "kind", "") == "section" &&
              Ops.get_string(defaults_all, "name", "") == "defaults"
          value = Ops.get_list(defaults_all, "value", [])
          Builtins.foreach(value) do |item|
            name_str = rm_quotes(Ops.get_string(item, "name", "NA"))
            value_str = rm_quotes(Ops.get_string(item, "value", "NA"))
            Ops.set(@defaults_items, name_str, value_str)
          end if value != nil &&
            value != []
        end
      end

      defaults_all = Convert.to_map(
        SCR.Read(path(".etc.multipath.all.defaults"))
      )
      if defaults_all != nil && defaults_all != {}
        if defaults_all != nil &&
            Ops.get_string(defaults_all, "kind", "NA") == "section" &&
              Ops.get_string(defaults_all, "name", "NA") == "defaults"
          value = Ops.get_list(defaults_all, "value", [])
          Builtins.foreach(value) do |item|
            name_str = rm_quotes(Ops.get_string(item, "name", "NA"))
            value_str = rm_quotes(Ops.get_string(item, "value", "NA"))
            Ops.set(@defaults_items, name_str, value_str)
          end if value != nil &&
            value != []
        end
      end
      true
    end

    #     read blacklist section from configuration file, store in blacklist_items
    def Read_BlacklistConfig
      value = []
      blacklist_all = Convert.to_map(
        SCR.Read(path(".etc.multipath.all.blacklist"))
      )

      if blacklist_all != nil && blacklist_all != {}
        if Ops.get_string(blacklist_all, "kind", "") == "section" &&
            Ops.get_string(blacklist_all, "name", "") == "blacklist"
          value = Ops.get_list(blacklist_all, "value", [])
          Builtins.foreach(value) do |e|
            item = {}
            if Ops.get_string(e, "kind", "") == "value"
              Ops.set(item, "name", rm_quotes(Ops.get_string(e, "name", "NA")))
              Ops.set(
                item,
                "value",
                rm_quotes(Ops.get_string(e, "value", "NA"))
              )
              Ops.set(item, "type", "node")
            elsif Ops.get_string(e, "kind", "") == "section"
              subsection = Ops.get_list(e, "value", [])
              if subsection == []
                next
              else
                sub_item = {}
                Builtins.foreach(subsection) do |sub_e|
                  if Ops.get_string(sub_e, "kind", "") == "value"
                    name = rm_quotes(Ops.get_string(sub_e, "name", ""))
                    value2 = rm_quotes(Ops.get_string(sub_e, "value", ""))
                    if Ops.greater_than(Builtins.size(name), 0) &&
                        Ops.greater_than(Builtins.size(value2), 0)
                      Ops.set(sub_item, name, value2)
                    end
                  end
                end
                product_str = rm_quotes(Ops.get_string(sub_item, "product", ""))
                vendor_str = rm_quotes(Ops.get_string(sub_item, "vendor", ""))
                if Builtins.size(product_str) == 0 ||
                    Builtins.size(vendor_str) == 0
                  next
                end
                Ops.set(
                  item,
                  "name",
                  rm_quotes(Ops.get_string(e, "name", "NA"))
                )
                Ops.set(item, "type", "device")
                Ops.set(item, "value", sub_item)
              end
            else
              next
            end
            @blacklist_items = Builtins.add(@blacklist_items, item)
          end if value != []
        end
      end

      # union built-in configuration and /etc/multipath.conf into one
      SCR.RegisterAgent(
        path(".content"),
        term(
          :ag_ini,
          term(
            :IniAgent,
            @builtin_multipath_conf_path,
            {
              "options"   => ["global_values", "repeat_names"],
              "comments"  => ["^[ \t]*#.*$", "^[ \t]*$"],
              "params"    => [
                {
                  "match" => [
                    "^[ \t]*([^ \t]+)[ \t]+([^ \t]+([ \t]*[^ \t]+)*)[ \t]*$",
                    "%s %s"
                  ]
                }
              ],
              "sections"  => [
                {
                  "begin" => ["[ \t]*([^ \t]+)*[ \t]*\\{[ \t]*$", "%s {"],
                  "end"   => ["^[ \t]*\\}[ \t]*$", "}"]
                }
              ],
              "subindent" => "\t"
            }
          )
        )
      )
      blacklist_all = Convert.to_map(SCR.Read(path(".content.all.blacklist")))
      SCR.UnregisterAgent(path(".content"))

      if blacklist_all != nil && blacklist_all != {}
        if Ops.get_string(blacklist_all, "kind", "") == "section" &&
            Ops.get_string(blacklist_all, "name", "") == "blacklist"
          value = Ops.get_list(blacklist_all, "value", [])
          Builtins.foreach(value) do |e|
            item = {}
            if Ops.get_string(e, "kind", "") == "value"
              Ops.set(item, "name", rm_quotes(Ops.get_string(e, "name", "NA")))
              Ops.set(
                item,
                "value",
                rm_quotes(Ops.get_string(e, "value", "NA"))
              )
              Ops.set(item, "type", "node")
            elsif Ops.get_string(e, "kind", "") == "section"
              subsection = Ops.get_list(e, "value", [])
              if subsection == []
                next
              else
                sub_item = {}
                Builtins.foreach(subsection) do |sub_e|
                  if Ops.get_string(sub_e, "kind", "") == "value"
                    name = rm_quotes(Ops.get_string(sub_e, "name", ""))
                    value2 = rm_quotes(Ops.get_string(sub_e, "value", ""))
                    if Ops.greater_than(Builtins.size(name), 0) &&
                        Ops.greater_than(Builtins.size(value2), 0)
                      Ops.set(sub_item, name, value2)
                    end
                  end
                end
                product_str = rm_quotes(Ops.get_string(sub_item, "product", ""))
                vendor_str = rm_quotes(Ops.get_string(sub_item, "vendor", ""))
                if Builtins.size(product_str) == 0 ||
                    Builtins.size(vendor_str) == 0
                  next
                end
                Ops.set(
                  item,
                  "name",
                  rm_quotes(Ops.get_string(e, "name", "NA"))
                )
                Ops.set(item, "type", "device")
                Ops.set(item, "value", sub_item)
              end
            else
              next
            end
            next if Builtins.contains(@blacklist_items, item) == true
            @blacklist_items = Builtins.add(@blacklist_items, item)
          end if value != []
        end
      end

      id = 0
      @blacklist_items = Builtins.maplist(@blacklist_items) do |e|
        Ops.set(e, "id", Builtins.tostring(id))
        id = Ops.add(id, 1)
        deep_copy(e)
      end
      true
    end


    #     read blacklist_exception section from configuration file,
    #     store in blacklist_exception_items
    def Read_BlacklistException_Config
      value = []
      blacklist_all = Convert.to_map(
        SCR.Read(path(".etc.multipath.all.blacklist_exceptions"))
      )

      if blacklist_all != nil && blacklist_all != {}
        if Ops.get_string(blacklist_all, "kind", "") == "section" &&
            Ops.get_string(blacklist_all, "name", "") == "blacklist_exceptions"
          value = Ops.get_list(blacklist_all, "value", [])
          Builtins.foreach(value) do |e|
            item = {}
            if Ops.get_string(e, "kind", "") == "value"
              Ops.set(item, "name", rm_quotes(Ops.get_string(e, "name", "NA")))
              Ops.set(item, "value", rm_quotes(Ops.get_string(e, "value", "")))
              Ops.set(item, "type", "node")
            elsif Ops.get_string(e, "kind", "") == "section"
              subsection = Ops.get_list(e, "value", [])
              if subsection == []
                next
              else
                sub_item = {}
                Builtins.foreach(subsection) do |sub_e|
                  if Ops.get_string(sub_e, "kind", "") == "value"
                    name = rm_quotes(Ops.get_string(sub_e, "name", ""))
                    value2 = rm_quotes(Ops.get_string(sub_e, "value", ""))
                    if Ops.greater_than(Builtins.size(name), 0) &&
                        Ops.greater_than(Builtins.size(value2), 0)
                      Ops.set(sub_item, name, value2)
                    end
                  end
                end
                product_str = rm_quotes(
                  Ops.get_string(sub_item, "product", "NA")
                )
                vendor_str = rm_quotes(Ops.get_string(sub_item, "vendor", "NA"))
                if Builtins.size(product_str) == 0 ||
                    Builtins.size(vendor_str) == 0
                  next
                end
                Ops.set(
                  item,
                  "name",
                  rm_quotes(Ops.get_string(e, "name", "NA"))
                )
                Ops.set(item, "type", "device")
                Ops.set(item, "value", sub_item)
              end
            else
              next
            end
            @blacklist_exception_items = Builtins.add(
              @blacklist_exception_items,
              item
            )
          end if value != []
        end
      end

      # union built-in configuration and /etc/multipath.conf into one
      SCR.RegisterAgent(
        path(".content"),
        term(
          :ag_ini,
          term(
            :IniAgent,
            @builtin_multipath_conf_path,
            {
              "options"   => ["global_values", "repeat_names"],
              "comments"  => ["^[ \t]*#.*$", "^[ \t]*$"],
              "params"    => [
                {
                  "match" => [
                    "^[ \t]*([^ \t]+)[ \t]+([^ \t]+([ \t]*[^ \t]+)*)[ \t]*$",
                    "%s %s"
                  ]
                }
              ],
              "sections"  => [
                {
                  "begin" => ["[ \t]*([^ \t]+)*[ \t]*\\{[ \t]*$", "%s {"],
                  "end"   => ["^[ \t]*\\}[ \t]*$", "}"]
                }
              ],
              "subindent" => "\t"
            }
          )
        )
      )
      blacklist_all = Convert.to_map(
        SCR.Read(path(".content.all.blacklist_exceptions"))
      )
      SCR.UnregisterAgent(path(".content"))

      if blacklist_all != nil && blacklist_all != {}
        if Ops.get_string(blacklist_all, "kind", "") == "section" &&
            Ops.get_string(blacklist_all, "name", "") == "blacklist"
          value = Ops.get_list(blacklist_all, "value", [])
          Builtins.foreach(value) do |e|
            item = {}
            if Ops.get_string(e, "kind", "") == "value"
              Ops.set(item, "name", rm_quotes(Ops.get_string(e, "name", "NA")))
              Ops.set(item, "value", rm_quotes(Ops.get_string(e, "value", "")))
              Ops.set(item, "type", "node")
            elsif Ops.get_string(e, "kind", "") == "section"
              subsection = Ops.get_list(e, "value", [])
              if subsection == []
                next
              else
                sub_item = {}
                Builtins.foreach(subsection) do |sub_e|
                  if Ops.get_string(sub_e, "kind", "") == "value"
                    name = rm_quotes(Ops.get_string(sub_e, "name", ""))
                    value2 = rm_quotes(Ops.get_string(sub_e, "value", ""))
                    if Ops.greater_than(Builtins.size(name), 0) &&
                        Ops.greater_than(Builtins.size(value2), 0)
                      Ops.set(sub_item, name, value2)
                    end
                  end
                end
                product_str = rm_quotes(
                  Ops.get_string(sub_item, "product", "NA")
                )
                vendor_str = rm_quotes(Ops.get_string(sub_item, "vendor", "NA"))
                if Builtins.size(product_str) == 0 ||
                    Builtins.size(vendor_str) == 0
                  next
                end
                Ops.set(
                  item,
                  "name",
                  rm_quotes(Ops.get_string(e, "name", "NA"))
                )
                Ops.set(item, "type", "device")
                Ops.set(item, "value", sub_item)
              end
            else
              next
            end
            next if Builtins.contains(@blacklist_exception_items, item) == true
            @blacklist_exception_items = Builtins.add(
              @blacklist_exception_items,
              item
            )
          end if value != []
        end
      end

      id = 0
      Builtins.foreach(@blacklist_exception_items) do |e|
        Ops.set(e, "id", Builtins.tostring(id))
        id = Ops.add(id, 1)
      end

      true
    end


    # read device section from configuration file, store in devices_items
    def Read_DeviceConfig
      id = 0
      devices_all = Convert.to_map(SCR.Read(path(".etc.multipath.all.devices")))

      if devices_all != nil && devices_all != {}
        if Ops.get_string(devices_all, "kind", "") == "section" &&
            Ops.get_string(devices_all, "name", "") == "devices"
          if Ops.get(devices_all, "value") != nil &&
              Ops.get_list(devices_all, "value", []) != []
            Builtins.foreach(Ops.get_list(devices_all, "value", [])) do |sub_section|
              item = {}
              if Ops.get_string(sub_section, "kind", "") != "section" ||
                  Ops.get_string(sub_section, "name", "") != "device"
                next
              end
              value = Ops.get_list(sub_section, "value", [])
              next if value == []
              Builtins.foreach(value) do |e|
                next if Ops.get_string(e, "kind", "") != "value"
                if Ops.get_string(e, "name", "") == "" ||
                    Ops.get_string(e, "value", "") == ""
                  next
                end
                name = rm_quotes(Ops.get_string(e, "name", "NA"))
                value2 = rm_quotes(Ops.get_string(e, "value", "NA"))
                Ops.set(item, name, value2)
              end
              # for configuration without "vendor" or "product", do not
              #    read it into Yast module.
              if Ops.get(item, "vendor", "") == "" ||
                  Ops.get(item, "product", "") == ""
                next
              end
              Ops.set(item, "id", Builtins.tostring(id))
              id = Ops.add(id, 1)
              @devices_items = Builtins.add(@devices_items, item)
            end
          end
        end
      end


      # union built-in configuration and /etc/multipath.conf into one
      SCR.RegisterAgent(
        path(".content"),
        term(
          :ag_ini,
          term(
            :IniAgent,
            @builtin_multipath_conf_path,
            {
              "options"   => ["global_values", "repeat_names"],
              "comments"  => ["^[ \t]*#.*$", "^[ \t]*$"],
              "params"    => [
                {
                  "match" => [
                    "^[ \t]*([^ \t]+)[ \t]+([^ \t]+([ \t]*[^ \t]+)*)[ \t]*$",
                    "%s %s"
                  ]
                }
              ],
              "sections"  => [
                {
                  "begin" => ["[ \t]*([^ \t]+)*[ \t]*\\{[ \t]*$", "%s {"],
                  "end"   => ["^[ \t]*\\}[ \t]*$", "}"]
                }
              ],
              "subindent" => "\t"
            }
          )
        )
      )
      devices_all = Convert.to_map(SCR.Read(path(".content.all.devices")))
      SCR.UnregisterAgent(path(".content"))

      if devices_all != nil && devices_all != {}
        if Ops.get_string(devices_all, "kind", "") == "section" &&
            Ops.get_string(devices_all, "name", "") == "devices"
          if Ops.get(devices_all, "value") != nil &&
              Ops.get_list(devices_all, "value", []) != []
            Builtins.foreach(Ops.get_list(devices_all, "value", [])) do |sub_section|
              item = {}
              if Ops.get_string(sub_section, "kind", "") != "section" ||
                  Ops.get_string(sub_section, "name", "") != "device"
                next
              end
              value = Ops.get_list(sub_section, "value", [])
              next if value == []
              Builtins.foreach(value) do |e|
                next if Ops.get_string(e, "kind", "") != "value"
                if Ops.get_string(e, "name", "") == "" ||
                    Ops.get_string(e, "value", "") == ""
                  next
                end
                name = rm_quotes(Ops.get_string(e, "name", "NA"))
                value2 = rm_quotes(Ops.get_string(e, "value", "NA"))
                Ops.set(item, name, value2)
              end
              # for configuration without "vendor" or "product", do not
              #    read it into Yast module.
              if Ops.get(item, "vendor", "") == "" ||
                  Ops.get(item, "product", "") == ""
                next
              end
              filter_ret = Builtins.filter(@devices_items) do |filter_e|
                if Ops.get_string(filter_e, "vendor", "") ==
                    Ops.get(item, "vendor", "NA") &&
                    Ops.get_string(filter_e, "product", "") ==
                      Ops.get(item, "product", "NA")
                  next true
                else
                  next false
                end
              end
              next if filter_ret != nil && filter_ret != []
              Ops.set(item, "id", Builtins.tostring(id))
              id = Ops.add(id, 1)
              @devices_items = Builtins.add(@devices_items, item)
            end
          end
        end
      end

      true
    end

    # update proper value in the widget which generated by Get_multipath_default_confs()
    def update_multipath_details(item)
      item = deep_copy(item)
      Builtins.foreach(@multipath_detail_items) do |item_symbol|
        update_handler = Convert.convert(
          Ops.get(@update_term_handlers, item_symbol),
          :from => "any",
          :to   => "void (map)"
        )
        if update_handler == nil
          Popup.Message(
            Builtins.sformat(
              "update term handler for %1 does not exist",
              item_symbol
            )
          )
          next
        end
        update_handler.call(item)
      end

      nil
    end

    # build defaults configuration entry in multipath configuration, this function make source code
    #    more clear
    def build_multipath_details
      confs_term = VBox(Empty())
      counter = 0
      item_per_line = 2
      line = HBox(Empty())

      Builtins.foreach(@multipath_detail_items) do |item_symbol|
        build_handler = Convert.convert(
          Ops.get(@build_term_handlers, item_symbol),
          :from => "any",
          :to   => "term (symbol)"
        )
        if build_handler == nil
          Popup.Message(
            Builtins.sformat(
              "build term handler for %1 does not exist",
              item_symbol
            )
          )
          next
        end
        line = Builtins.add(line, HWeight(1, build_handler.call(:all)))
        counter = Ops.add(counter, 1)
        if Ops.modulo(counter, item_per_line) == 0
          confs_term = Builtins.add(confs_term, line)
          line = HBox(Empty())
        end
      end
      deep_copy(confs_term)
    end

    # check if user input is legal, and popup necessary information
    def check_mp_config(item)
      item = deep_copy(item)
      result = true
      prop_info = _("Illegal parameters:\n")

      Builtins.foreach(@multipath_brief_items) do |item_name|
        ret = {}
        check_handler = Convert.convert(
          Ops.get(@check_handlers, item_name),
          :from => "any",
          :to   => "map (map)"
        )
        if check_handler != nil
          ret = check_handler.call(item)
          if ret == nil
            Popup.Message(
              Builtins.sformat(
                "check handler for %1 is not implemented yet",
                item_name
              )
            )
          elsif Ops.get_boolean(ret, "result", false) == false
            prop_info = Ops.add(prop_info, Ops.get_string(ret, "info", ""))
            result = false
          end
        else
          Popup.Message(
            Builtins.sformat("check handler does not exist for %1", item_name)
          )
        end
      end

      if result == false
        Popup.Message(prop_info)
        return result
      end

      Builtins.foreach(@multipath_detail_items) do |item_name|
        ret = {}
        check_handler = Convert.convert(
          Ops.get(@check_handlers, item_name),
          :from => "any",
          :to   => "map (map)"
        )
        if check_handler != nil
          ret = check_handler.call(item)
          if ret == nil
            Popup.Message(
              Builtins.sformat(
                "check handler for %1 is not implemented yet",
                item_name
              )
            )
          end
          if Ops.get_boolean(ret, "result", false) == false
            prop_info = Ops.add(prop_info, Ops.get_string(ret, "info", ""))
            result = false
          end
        else
          Popup.Message(
            Builtins.sformat("check handler does not exist for %1", item_name)
          )
        end
      end

      if result == false
        Popup.Message(prop_info)
        return result
      end

      # duplicated configuraton checking
      Builtins.foreach(@multipaths_items) do |e|
        if Ops.get_string(e, "id", "NA") != Ops.get_string(item, "id", "na") &&
            Ops.get_string(e, "wwid", "NA") ==
              Ops.get_string(item, "wwid", "na")
          prop_info = _("Duplicated configuration.")
          Popup.Message(prop_info)
          result = false
          raise Break
        end
      end

      result
    end

    #     if table_item == nil, means add a new item
    def Edit_Multipaths_Dialog(table_item)
      table_item = deep_copy(table_item)
      cur_item = {}
      if table_item != nil
        config_item = Builtins.filter(@multipaths_items) do |item|
          Ops.get_string(item, "wwid", "NA") ==
            Ops.get_string(table_item, 2, "")
        end
        cur_item = Ops.get(config_item, 0)
        return if cur_item == nil
      end

      # used for store undecided input
      temp_cur_item = deep_copy(cur_item)
      Ops.set(
        temp_cur_item,
        "id",
        cur_item == {} ?
          get_newid(@multipaths_items) :
          Ops.get_string(cur_item, "id", "0")
      )

      multipaths_item_edit = VBox(
        HWeight(1, HBox(build_wwid_term(:dummy))),
        HWeight(1, HBox(build_alias_term(:dummy))),
        VBox(
          ReplacePoint(
            Id(:replace_mp_defaults_confs_id),
            VBox(
              Left(
                HBox(
                  CheckBox(
                    Id(:show_details_id),
                    Opt(:notify),
                    _("Show Details"),
                    false
                  )
                )
              )
            )
          )
        )
      )
      UI.OpenDialog(
        Opt(:decorated),
        VBox(
          multipaths_item_edit,
          HSpacing(1),
          HBox(
            PushButton(Id(:ok), Opt(:default), Label.OKButton),
            PushButton(Id(:cancel), Label.CancelButton)
          )
        )
      )

      update_wwid_term(temp_cur_item)
      update_alias_term(temp_cur_item)
      UI.SetFocus(Id(:wwid))
      @temp_string_values = {}
      ret = nil

      while true
        ret = UI.UserInput
        if @replacewidget_notify == true
          @replacewidget_notify = false
          next
        end
        if ret == :show_details_id
          checked = Convert.to_boolean(
            UI.QueryWidget(Id(:show_details_id), :Value)
          )
          if checked == true
            UI.ReplaceWidget(
              Id(:replace_mp_defaults_confs_id),
              VBox(
                Left(
                  HBox(
                    CheckBox(
                      Id(:show_details_id),
                      Opt(:notify),
                      _("Show Details"),
                      true
                    )
                  )
                ),
                build_multipath_details
              )
            )
            update_multipath_details(temp_cur_item)
          else
            UI.ReplaceWidget(
              Id(:replace_mp_defaults_confs_id),
              VBox(
                Left(
                  HBox(
                    CheckBox(
                      Id(:show_details_id),
                      Opt(:notify),
                      _("Show Details"),
                      false
                    )
                  )
                )
              )
            )
          end
        elsif Builtins.contains(@multipath_detail_items, Convert.to_symbol(ret)) == true ||
            Builtins.contains(@multipath_brief_items, Convert.to_symbol(ret)) == true
          handler = Convert.convert(
            Ops.get(@default_item_handlers, Convert.to_symbol(ret)),
            :from => "any",
            :to   => "map (map)"
          )
          if handler != nil
            temp_cur_item = handler.call(temp_cur_item)
          else
            Popup.Message(Builtins.sformat("Can not find handler for %1", ret))
          end
        elsif ret == :ok
          if check_mp_config(temp_cur_item) == true
            Multipath.config_modified = true
            # update the multipaths configuraton items
            if table_item != nil
              @multipaths_items = Builtins.maplist(@multipaths_items) do |item|
                if Ops.get_string(table_item, 2, "NA") ==
                    Ops.get_string(item, "wwid", "na")
                  next deep_copy(temp_cur_item)
                else
                  next deep_copy(item)
                end
              end
            else
              @multipaths_items = Builtins.add(@multipaths_items, temp_cur_item)
            end
            break
          end
        elsif ret == :cancel
          break
        else
          Popup.Message(
            Builtins.sformat("Edit_Multipaths_Dialog: unexpected ret %1", ret)
          )
        end
      end

      UI.CloseDialog
      nil
    end

    def Multipath_Dialog(option)
      if option == :multipaths_del_id
        cur =  UI.QueryWidget(Id(:multipaths_table_id), :CurrentItem).to_i
        cur_item = Convert.to_term(
          UI.QueryWidget(Id(:multipaths_table_id), term(:Item, cur))
        )

        @multipaths_items = Builtins.filter(@multipaths_items) do |item|
          _wwid = Builtins.sformat("%1", Ops.get_string(cur_item, 2, "NA"))
          ret = false
          ret = Ops.get_string(item, "wwid", "NA") != _wwid
          Multipath.config_modified = true if ret == false
          ret
        end
        UI.ChangeWidget(
          Id(:multipaths_table_id),
          :Items,
          Build_MultipathsTable()
        )
      elsif option == :multipaths_edit_id || option == :multipaths_table_id
        cur = Convert.to_integer(
          UI.QueryWidget(Id(:multipaths_table_id), :CurrentItem)
        )
        cur_item = Convert.to_term(
          UI.QueryWidget(Id(:multipaths_table_id), term(:Item, cur))
        )
        Edit_Multipaths_Dialog(cur_item)
        UI.ChangeWidget(
          Id(:multipaths_table_id),
          :Items,
          Build_MultipathsTable()
        )
        UI.ChangeWidget(Id(:multipaths_table_id), :CurrentItem, cur)
      elsif option == :multipaths_add_id
        Edit_Multipaths_Dialog(nil)
        UI.ChangeWidget(
          Id(:multipaths_table_id),
          :Items,
          Build_MultipathsTable()
        )
      else
        Popup.Message(
          Builtins.sformat("Multipath_Dialog: unexpected option %1", option)
        )
      end

      nil
    end

    #     build defaults configuration widget
    def build_defaults_item(item)
      item = deep_copy(item)
      ret = Empty()
      name = Ops.get_string(item, "name", "NA")
      item_name = Builtins.symbolof(Builtins.toterm(name))

      build_handler = Convert.convert(
        Ops.get(@build_term_handlers, item_name),
        :from => "any",
        :to   => "term (symbol)"
      )
      if build_handler == nil
        Popup.Message(
          Builtins.sformat("handler for %1 is not implemented yet", item_name)
        )
      else
        ret = build_handler.call(:all)
      end
      deep_copy(ret)
    end

    def update_defaults_item(item)
      item = deep_copy(item)
      name = Ops.get_string(item, "name", "NA")
      value = Ops.get_string(item, "value", "NA")
      item_map = {}
      item_name = Builtins.symbolof(Builtins.toterm(name))
      Ops.set(item_map, name, value)

      update_handler = Convert.convert(
        Ops.get(@update_term_handlers, item_name),
        :from => "any",
        :to   => "void (map)"
      )
      if update_handler == nil
        Popup.Message(
          Builtins.sformat("handler for %1 is not implemented yet", item_name)
        )
      else
        update_handler.call(item_map)
        UI.SetFocus(Id(item_name))
      end

      nil
    end


    # do not do with number id
    def defaults_symbol_to_str(value)
      value = deep_copy(value)
      str = nil

      if value != nil && Ops.is_symbol?(value)
        if value == :combobox_df_non_id
          str = ""
        elsif value == :combobox_df_roundrobin_id
          str = "round-robin 0"
        elsif value == :combobox_df_multibus_id
          str = "multibus"
        elsif value == :combobox_df_readsector0_id
          str = "readsector0"
        elsif value == :combobox_df_tur_id
          str = "tur"
        elsif value == :combobox_df_emc_clariion_id
          str = "emc_clariion"
        elsif value == :combobox_df_hp_sw_id
          str = "hp_sw"
        elsif value == :combobox_df_directio_id
          str = "directio"
        elsif value == :combobox_df_priorities_id
          str = "priorities"
        elsif value == :combobox_df_uniform_id
          str = "uniform"
        elsif value == :combobox_df_manual_id
          str = "manual"
        elsif value == :combobox_df_immediate_id
          str = "immediate"
        elsif value == :combobox_df_queue_id
          str = "queue"
        elsif value == :combobox_df_fail_id
          str = "fail"
        elsif value == :combobox_df_yes_id
          str = "yes"
        elsif value == :combobox_df_no_id
          str = "no"
        else
          Popup.Message(Builtins.sformat("unknow value: `%1'", value))
        end
      else
        Popup.Message(Builtins.sformat("paramter is not symbol: `%1'", value))
      end
      str
    end

    def check_df_config(item)
      item = deep_copy(item)
      ret = {}
      result = false
      prop_info = _("Illegal parameter:") + "\n"
      name_str = Ops.get_string(item, "name", "NA")
      value_str = Ops.get_string(item, "value", "NA")
      item_name = Builtins.symbolof(Builtins.toterm(name_str))
      check_handler = Convert.convert(
        Ops.get(@check_handlers, item_name),
        :from => "any",
        :to   => "map (map)"
      )

      if check_handler == nil
        Popup.Message(
          Builtins.sformat("can not find check handler for %1", item_name)
        )
        result = false
      else
        item_map = {}
        Ops.set(item_map, name_str, value_str)
        ret = check_handler.call(item_map)
        if ret == nil
          Popup.Message(
            Builtins.sformat(
              "check handler for %1 is not implemented yet",
              item_name
            )
          )
          result = false
        end
        result = Ops.get_boolean(ret, "result", false)
        if result == false
          prop_info = Ops.add(prop_info, Ops.get_string(ret, "info", ""))
          Popup.Message(prop_info)
        end
      end
      result
    end

    def Edit_Defaults_Dialog(table_item)
      table_item = deep_copy(table_item)
      cur_item_name = Ops.get_string(table_item, 1, "NA")
      cur_item_value = Ops.get(@defaults_items, cur_item_name, "NA")
      cur_item = { "name" => cur_item_name, "value" => cur_item_value }
      @temp_string_values = {}

      UI.OpenDialog(
        Opt(:decorated),
        VBox(
          HBox(HWeight(1, build_defaults_item(cur_item))),
          HSpacing(1),
          HBox(
            PushButton(Id(:ok), Label.OKButton),
            PushButton(Id(:cancel), Opt(:default), Label.CancelButton)
          )
        )
      )
      update_defaults_item(cur_item)

      ret = nil
      while true
        value = nil
        ret = UI.UserInput
        if @replacewidget_notify == true
          @replacewidget_notify = false
          next
        end

        if Builtins.contains(@defaults_section_items, Convert.to_symbol(ret)) == true
          default_handler = Convert.convert(
            Ops.get(@default_item_handlers, ret),
            :from => "any",
            :to   => "map (map)"
          )
          if default_handler != nil
            item_map = {}
            name_str = Ops.get_string(cur_item, "name", "NA")
            value_str = Ops.get_string(cur_item, "value", "NA")
            Ops.set(item_map, name_str, value_str)
            item_map = default_handler.call(item_map)
            Ops.set(cur_item, "value", Ops.get_string(item_map, name_str, "NA"))
          else
            Popup.Message(
              Builtins.sformat("handler for %1 is not implemented yet", ret)
            )
          end
        elsif ret == :ok
          if check_df_config(cur_item) == true
            name_str = Ops.get_string(cur_item, "name", "NA")
            value_str = Ops.get_string(cur_item, "value", "")
            Ops.set(@defaults_items, name_str, value_str)
            Multipath.config_modified = true
            break
          end
        else
          break
        end
      end
      UI.CloseDialog
      nil
    end

    def Defaults_Dialog
      Wizard.SetContentsButtons(
        @caption,
        @contents,
        Ops.get_string(@HELPS, "Defaults_help", ""),
        Label.BackButton,
        Label.OKButton
      )
      UI.ReplaceWidget(Id(:contents_replace_id), @defaults_config)
      UI.ChangeWidget(Id(:defaults_table_id), :Items, Build_DefaultsTable())

      ret = nil
      while true
        ret = UI.UserInput
        if ret == :defaults_del_id
          cur = Convert.to_symbol(
            UI.QueryWidget(Id(:defaults_table_id), :CurrentItem)
          )
          table_item = Convert.to_term(
            UI.QueryWidget(Id(:defaults_table_id), term(:Item, cur))
          )
          name_str = Ops.get_string(table_item, 1, "NA")
          Ops.set(@defaults_items, name_str, "")
          UI.ChangeWidget(Id(:defaults_table_id), :Items, Build_DefaultsTable())
          UI.ChangeWidget(Id(:defaults_table_id), :CurrentItem, cur)
          next
        elsif ret == :defaults_edit_id || ret == :defaults_table_id
          cur = Convert.to_symbol(
            UI.QueryWidget(Id(:defaults_table_id), :CurrentItem)
          )
          cur_item = Convert.to_term(
            UI.QueryWidget(Id(:defaults_table_id), term(:Item, cur))
          )
          Edit_Defaults_Dialog(cur_item)
          UI.ChangeWidget(Id(:defaults_table_id), :Items, Build_DefaultsTable())
          UI.ChangeWidget(Id(:defaults_table_id), :CurrentItem, cur)
          next
        else
          break
        end
      end
      deep_copy(ret)
    end

    def Update_Multipaths_Config(table_item, config_item)
      table_item = deep_copy(table_item)
      config_item = deep_copy(config_item)
      return if table_item == nil || config_item == nil

      @multipaths_items = Builtins.maplist(@multipaths_items) do |item|
        if Ops.get_string(table_item, 1, "NA") ==
            Ops.get_string(item, "alias", "na")
          next deep_copy(config_item)
        else
          next deep_copy(item)
        end
      end

      nil
    end

    def Build_Multipath_Conf
      # defaults section
      # 	if value is empty, only write name into configuration file.
      defaults_value = []
      Builtins.foreach(@defaults_items) do |name_str, value_str|
        item_name = Builtins.symbolof(Builtins.toterm(name_str))
        entry = { "comment" => "", "kind" => "value", "type" => 0 }
        Ops.set(entry, "name", name_str)
        Ops.set(entry, "value", add_quotes(value_str))
        if Builtins.contains(@defaults_section_items, item_name) == true &&
            Ops.get_string(entry, "value", "") != ""
          defaults_value = Builtins.add(defaults_value, entry)
        end
      end
      defaults_root = {
        "comment" => "#\n" +
          "# This configuration file is generated by Yast, do not modify it\n" +
          "# manually please. \n" +
          "#\n",
        "file"    => -1,
        "kind"    => "section",
        "name"    => "defaults",
        "type"    => 0,
        "value"   => defaults_value
      }

      # blacklist section
      # 	if value is empty, do not write name into configuration file.
      blacklist_value = []
      Builtins.foreach(@blacklist_items) do |e|
        entry = {}
        if Ops.get_string(e, "type", "") == "device"
          sub_e = Ops.get_map(e, "value", {})
          next if sub_e == {}
          if Builtins.size(Ops.get_string(sub_e, "vendor", "")) == 0 ||
              Builtins.size(Ops.get_string(sub_e, "product", "")) == 0
            next
          end
          Ops.set(entry, "comment", "")
          Ops.set(entry, "file", -1)
          Ops.set(entry, "kind", "section")
          Ops.set(entry, "name", "device")
          Ops.set(entry, "type", 0)
          Ops.set(
            entry,
            "value",
            [
              {
                "comment" => "",
                "kind"    => "value",
                "name"    => "vendor",
                "type"    => 0,
                "value"   => add_quotes(Ops.get_string(sub_e, "vendor", ""))
              },
              {
                "comment" => "",
                "kind"    => "value",
                "name"    => "product",
                "type"    => 0,
                "value"   => add_quotes(Ops.get_string(sub_e, "product", ""))
              }
            ]
          )
        elsif Ops.greater_than(Builtins.size(Ops.get_string(e, "name", "")), 0) &&
            Ops.greater_than(Builtins.size(Ops.get_string(e, "value", "")), 0)
          Ops.set(entry, "comment", "")
          Ops.set(entry, "kind", "value")
          Ops.set(entry, "name", Ops.get_string(e, "name", "NA"))
          Ops.set(entry, "type", 0)
          Ops.set(entry, "value", add_quotes(Ops.get_string(e, "value", "")))
        else
          Ops.set(entry, "comment", "")
          Ops.set(entry, "kind", "value")
          Ops.set(entry, "name", Ops.get_string(e, 0, "NA"))
          Ops.set(entry, "type", 0)
          Ops.set(entry, "value", add_quotes(Ops.get_string(e, 1, "NA")))
        end
        blacklist_value = Builtins.add(blacklist_value, entry)
      end
      blacklist_root = {
        "comment" => "",
        "file"    => -1,
        "kind"    => "section",
        "name"    => "blacklist",
        "type"    => 0,
        "value"   => blacklist_value
      }


      # blacklist_exception section
      # 	if value is empty, do not write name into configuration file.
      blacklist_exception_value = []
      Builtins.foreach(@blacklist_exception_items) do |e|
        entry = {}
        if Ops.get_string(e, "type", "") == "device"
          sub_e = Ops.get_map(e, "value", {})
          next if sub_e == {}
          if Builtins.size(Ops.get_string(sub_e, "vendor", "")) == 0 ||
              Builtins.size(Ops.get_string(sub_e, "product", "")) == 0
            next
          end
          Ops.set(entry, "comment", "")
          Ops.set(entry, "file", -1)
          Ops.set(entry, "kind", "section")
          Ops.set(entry, "name", "device")
          Ops.set(entry, "type", 0)
          Ops.set(
            entry,
            "value",
            [
              {
                "comment" => "",
                "kind"    => "value",
                "name"    => "vendor",
                "type"    => 0,
                "value"   => add_quotes(Ops.get_string(sub_e, "vendor", ""))
              },
              {
                "comment" => "",
                "kind"    => "value",
                "name"    => "product",
                "type"    => 0,
                "value"   => add_quotes(Ops.get_string(sub_e, "product", ""))
              }
            ]
          )
        elsif Ops.greater_than(Builtins.size(Ops.get_string(e, "name", "")), 0) &&
            Ops.greater_than(Builtins.size(Ops.get_string(e, "value", "")), 0)
          Ops.set(entry, "comment", "")
          Ops.set(entry, "kind", "value")
          Ops.set(entry, "name", Ops.get_string(e, "name", "NA"))
          Ops.set(entry, "type", 0)
          Ops.set(entry, "value", add_quotes(Ops.get_string(e, "value", "")))
        else
          Ops.set(entry, "comment", "")
          Ops.set(entry, "kind", "value")
          Ops.set(entry, "name", Ops.get_string(e, 0, "NA"))
          Ops.set(entry, "type", 0)
          Ops.set(entry, "value", add_quotes(Ops.get_string(e, 1, "NA")))
        end
        blacklist_exception_value = Builtins.add(
          blacklist_exception_value,
          entry
        )
      end
      blacklist_exception_root = {
        "comment" => "",
        "file"    => -1,
        "kind"    => "section",
        "name"    => "blacklist_exceptions",
        "type"    => 0,
        "value"   => blacklist_exception_value
      }

      # multipaths section
      # 	if value is empty, do not write name into configuration file.
      multipaths_value = []
      Builtins.foreach(@multipaths_items) do |e|
        value = []
        Builtins.foreach(
          Convert.convert(e, :from => "map", :to => "map <string, string>")
        ) do |k, v|
          if k != "id" && v != nil && Ops.greater_than(Builtins.size(v), 0)
            value = Builtins.add(
              value,
              {
                "comment" => "",
                "kind"    => "value",
                "name"    => k,
                "type"    => 0,
                "value"   => add_quotes(v)
              }
            )
          end
        end
        subsection = {
          "comment" => "",
          "file"    => -1,
          "kind"    => "section",
          "name"    => "multipath",
          "type"    => 0,
          "value"   => value
        }
        multipaths_value = Builtins.add(multipaths_value, subsection)
      end
      multipaths_root = {
        "comment" => "",
        "file"    => -1,
        "kind"    => "section",
        "name"    => "multipaths",
        "type"    => 0,
        "value"   => multipaths_value
      }

      # devices section
      # 	if value is empty, do not write name into configuration file.
      devices_value = []
      Builtins.maplist(@devices_items) do |e|
        value = []
        Builtins.foreach(
          Convert.convert(e, :from => "map", :to => "map <string, string>")
        ) do |k, v|
          if k != "id" && v != nil && Ops.greater_than(Builtins.size(v), 0)
            value = Builtins.add(
              value,
              {
                "comment" => "",
                "kind"    => "value",
                "name"    => k,
                "type"    => 0,
                "value"   => add_quotes(v)
              }
            )
          end
        end
        subsection = {
          "comment" => "",
          "file"    => -1,
          "kind"    => "section",
          "name"    => "device",
          "type"    => 0,
          "value"   => value
        }
        devices_value = Builtins.add(devices_value, subsection)
      end
      devices_root = {
        "comment" => "",
        "file"    => -1,
        "kind"    => "section",
        "name"    => "devices",
        "type"    => 0,
        "value"   => devices_value
      }

      all_value = [
        defaults_root,
        blacklist_root,
        blacklist_exception_root,
        multipaths_root,
        devices_root
      ]
      all_root = {
        "comment" => "",
        "file"    => -1,
        "kind"    => "section",
        "name"    => "",
        "type"    => -1,
        "value"   => all_value
      }
      deep_copy(all_root)
    end



    def delete_blacklist_item(table_item)
      table_item = deep_copy(table_item)
      @blacklist_items = Builtins.filter(@blacklist_items) do |e|
        match = true
        value = nil
        if Ops.get_string(table_item, 1, "") == "device" &&
            Ops.get_string(e, "type", "") == "device"
          sub_e = Ops.get_map(e, "value", {})
          if sub_e != {}
            value = Builtins.sformat(
              @device_template,
              Ops.get_string(sub_e, "vendor", "NA"),
              Ops.get_string(sub_e, "product", "NA")
            )
            match = Ops.get_string(e, "name", "") ==
              Ops.get_string(table_item, 1, "na") &&
              value == Ops.get_string(table_item, 2, "na")
          end
        elsif Ops.get_string(e, "type", "") == "node"
          match = Ops.get_string(e, "name", "") ==
            Ops.get_string(table_item, 1, "na") &&
            Ops.get_string(e, "value", "") ==
              Ops.get_string(table_item, 2, "na")
        else
          match = false
        end
        Multipath.config_modified = true if match == true
        !match
      end

      nil
    end

    def check_bl_config(item)
      item = deep_copy(item)
      prop_info = _("Illegal parameters:") + "\n"
      type_str = ""
      result = false
      ret = {}
      item_map = {}
      check_handler = nil

      type_str = Ops.get_string(item, "type", "")
      if type_str == "device"
        sub_item = Ops.get_map(item, "value", {})
        if sub_item == {}
          Popup.Message(Builtins.sformat("can not find sub_item from %1", item))
          return false
        end
        vendor_str = Ops.get_string(sub_item, "vendor", "")
        product_str = Ops.get_string(sub_item, "product", "")

        check_handler = Convert.convert(
          Ops.get(@check_handlers, :vendor),
          :from => "any",
          :to   => "map (map)"
        )
        if check_handler == nil
          Popup.Message("check handler for `vendor does not exist")
          return false
        end
        Ops.set(item_map, "vendor", vendor_str)
        ret = check_handler.call(item_map)
        result = Ops.get_boolean(ret, "result", false)
        if result == false
          prop_info = Ops.add(prop_info, Ops.get_string(ret, "info", ""))
        end

        check_handler = Convert.convert(
          Ops.get(@check_handlers, :product),
          :from => "any",
          :to   => "map (map)"
        )
        if check_handler == nil
          Popup.Message("check handler for `product does not exist")
          return false
        end
        Ops.set(item_map, "product", product_str)
        ret = check_handler.call(item_map)
        result = Ops.get_boolean(ret, "result", false)
        if result == false
          prop_info = Ops.add(prop_info, Ops.get_string(ret, "info", ""))
        end
      elsif type_str == "node"
        name_str = Ops.get_string(item, "name", "NA")
        value_str = Ops.get_string(item, "value", "")
        item_name = Builtins.symbolof(Builtins.toterm(name_str))
        check_handler = Convert.convert(
          Ops.get(@check_handlers, item_name),
          :from => "any",
          :to   => "map (map)"
        )
        if check_handler == nil
          Popup.Message(
            Builtins.sformat("check handler for %1 does not exist", item_name)
          )
          return false
        end
        Ops.set(item_map, name_str, value_str)
        ret = check_handler.call(item_map)
        result = Ops.get_boolean(ret, "result", false)
        if result == false
          prop_info = Ops.add(prop_info, Ops.get_string(ret, "info", ""))
        end
      else
        Popup.Message(
          Builtins.sformat("check_bl_config: unexpected type %1", type_str)
        )
        return false
      end

      if result == false
        Popup.Message(prop_info)
        return result
      end
      Builtins.foreach(@blacklist_items) do |e|
        if e == {}
          result = true
          raise Break
        end
        next if Ops.get_string(e, "id", "") == Ops.get_string(item, "id", "na")
        if Ops.get_string(e, "type", "") == "device"
          sub_e = Ops.get_map(e, "value", {})
          sub_item = Ops.get_map(item, "value", {})
          if sub_e != {} && sub_item != {}
            if Ops.get_string(sub_item, "vendor", "NA") ==
                Ops.get_string(sub_e, "vendor", "") &&
                Ops.get_string(sub_item, "product", "NA") ==
                  Ops.get_string(sub_e, "product", "")
              result = false
              raise Break
            end
          end
        else
          if Ops.get_string(item, "name", "NA") == Ops.get_string(e, "name", "") &&
              Ops.get_string(item, "value", "NA") ==
                Ops.get_string(e, "value", "")
            result = false
            raise Break
          end
        end
      end

      Popup.Message(_("Duplicated configuration.")) if result == false

      result
    end

    def build_edit_blacklist_terms(item)
      item = deep_copy(item)
      ret = Empty()
      type_str = Ops.get_string(item, "type", "")
      if type_str == "node"
        name_str = Ops.get_string(item, "name", "NA")
        item_name = Builtins.symbolof(Builtins.toterm(name_str))
        build_handler = Convert.convert(
          Ops.get(@build_term_handlers, item_name),
          :from => "any",
          :to   => "term (symbol)"
        )
        if build_handler == nil
          Popup.Message(
            Builtins.sformat(
              "build_edit_blacklist_terms: build handler for %1 does not exist",
              item_name
            )
          )
        else
          ret = VBox(
            HBox(TextEntry(Id(:blacklist_item), _("item"), "")),
            HBox(build_handler.call(:all))
          )
        end
      elsif type_str == "device"
        ret = VBox(
          HBox(TextEntry(Id(:blacklist_item), _("item"), "")),
          HBox(build_vendor_term(:all)),
          HBox(build_product_term(:all))
        )
      else
        Popup.Message(
          Builtins.sformat(
            "build_edit_blacklist_terms: unexpected type %1",
            type_str
          )
        )
      end
      deep_copy(ret)
    end

    def update_edit_blacklist_items(item)
      item = deep_copy(item)
      type_str = Ops.get_string(item, "type", "NA")
      map_item = {}

      if type_str == "device"
        UI.ChangeWidget(Id(:blacklist_item), :Value, "device")
        UI.ChangeWidget(Id(:blacklist_item), :Enabled, false)

        sub_item = Ops.get_map(item, "value", {})
        if sub_item == {}
          Popup.Message(Builtins.sformat("No value in subitem `%1'", item))
          return
        end
        vendor_str = Ops.get_string(sub_item, "vendor", "")
        product_str = Ops.get_string(sub_item, "product", "")
        if Builtins.contains(@blacklist_section_items, :vendor) == false ||
            Builtins.contains(@blacklist_section_items, :product) == false
          Popup.Message("`vendor or `product is not in valid blacklist items")
          return
        end
        update_handler = Convert.convert(
          Ops.get(@update_term_handlers, :vendor),
          :from => "any",
          :to   => "void (map)"
        )
        if update_handler == nil
          Popup.Message(
            "update_edit_blacklist_items: update handler for `vendor does not exist"
          )
          return
        else
          map_item2 = {}
          Ops.set(map_item2, "vendor", vendor_str)
          update_handler.call(map_item2)
        end
        update_handler = Convert.convert(
          Ops.get(@update_term_handlers, :product),
          :from => "any",
          :to   => "void (map)"
        )
        if update_handler == nil
          Popup.Message(
            "update_edit_blacklist_items: update handler for `product does not exist"
          )
          return
        else
          map_item2 = {}
          Ops.set(map_item2, "product", product_str)
          update_handler.call(map_item2)
        end
      else
        name_str = Ops.get_string(item, "name", "NA")
        value_str = Ops.get_string(item, "value", "")
        Ops.set(map_item, name_str, value_str)
        item_name = Builtins.symbolof(Builtins.toterm(name_str))

        UI.ChangeWidget(Id(:blacklist_item), :Value, name_str)
        UI.ChangeWidget(Id(:blacklist_item), :Enabled, false)

        if Builtins.contains(@blacklist_section_items, item_name) == true
          update_handler = Convert.convert(
            Ops.get(@update_term_handlers, item_name),
            :from => "any",
            :to   => "void (map)"
          )
          if update_handler != nil
            update_handler.call(map_item)
          else
            Popup.Message(
              Builtins.sformat(
                "update_edit_blacklist_items: update handler for %1 does not exist",
                item_name
              )
            )
          end
        else
          Popup.Message(
            Builtins.sformat(
              "item %1 is not in valid blacklist items",
              item_name
            )
          )
        end
      end

      nil
    end

    def Edit_Blacklist_Dialog(table_item)
      table_item = deep_copy(table_item)
      config_item = Builtins.filter(@blacklist_items) do |item|
        match = true
        if Ops.get_string(table_item, 1, "NA") == "device" &&
            Ops.get_string(item, "type", "NA") == "device"
          sub_item = Ops.get_map(item, "value", {})
          value = Builtins.sformat(
            @device_template,
            Ops.get_string(sub_item, "vendor", "NA"),
            Ops.get_string(sub_item, "product", "NA")
          )
          match = value == Ops.get_string(table_item, 2, "NA")
        elsif Ops.get_string(table_item, 1, "NA") != "device" &&
            Ops.get_string(item, "type", "NA") == "node"
          match = Ops.get_string(item, "name", "NA") ==
            Ops.get_string(table_item, 1, "na") &&
            Ops.get_string(item, "value", "NA") ==
              Ops.get_string(table_item, 2, "na")
        else
          match = false
        end
        match
      end
      cur_item = Ops.get(config_item, 0, {})
      return if cur_item == {}

      UI.OpenDialog(
        VBox(
          build_edit_blacklist_terms(cur_item),
          HSpacing(1),
          HBox(
            PushButton(Id(:ok), Label.OKButton),
            PushButton(Id(:cancel), Opt(:default), Label.CancelButton)
          )
        )
      )
      update_edit_blacklist_items(cur_item)

      ret = nil
      new_item = {}
      while true
        ret = UI.UserInput
        if @replacewidget_notify == true
          @replacewidget_notify = false
          next
        end

        if Builtins.contains(@blacklist_section_items, Convert.to_symbol(ret)) == true
          # do not handle, `ok will do with the value
          next
        elsif ret == :ok
          type_str = Ops.get_string(cur_item, "type", "")
          if type_str == "device"
            Ops.set(
              new_item,
              "name",
              UI.QueryWidget(Id(:blacklist_item), :Value)
            )
            Ops.set(new_item, "type", "device")
            vendor_str = rm_quotes(
              Convert.to_string(UI.QueryWidget(Id(:vendor), :Value))
            )
            product_str = rm_quotes(
              Convert.to_string(UI.QueryWidget(Id(:product), :Value))
            )
            sub_item = { "vendor" => vendor_str, "product" => product_str }
            Ops.set(new_item, "value", sub_item)
            Ops.set(new_item, "id", Ops.get_string(cur_item, "id", ""))
          elsif type_str == "node"
            name_str = Ops.get_string(cur_item, "name", "NA")
            id = Builtins.symbolof(Builtins.toterm(name_str))
            Ops.set(new_item, "type", "node")
            Ops.set(
              new_item,
              "name",
              rm_quotes(
                Convert.to_string(UI.QueryWidget(Id(:blacklist_item), :Value))
              )
            )
            Ops.set(
              new_item,
              "value",
              rm_quotes(Convert.to_string(UI.QueryWidget(Id(id), :Value)))
            )
            Ops.set(new_item, "id", Ops.get_string(cur_item, "id", ""))
          else
            Popup.Message(Builtins.sformat("Unexpected item type %1", type_str))
          end
          if check_bl_config(new_item) == true
            Multipath.config_modified = true
            @blacklist_items = Builtins.maplist(@blacklist_items) do |item|
              match = true
              if Ops.get_string(table_item, 1, "") == "device" &&
                  Ops.get_string(item, "type", "") == "device"
                sub_item = Ops.get_map(item, "value", {})
                value = Builtins.sformat(
                  @device_template,
                  Ops.get_string(sub_item, "vendor", "NA"),
                  Ops.get_string(sub_item, "product", "NA")
                )
                match = Ops.get_string(item, "name", "NA") ==
                  Ops.get_string(table_item, 1, "") &&
                  value == Ops.get_string(table_item, 2, "")
              elsif Ops.get_string(table_item, 1, "") != "device" &&
                  Ops.get_string(item, "type", "") == "node"
                match = Ops.get_string(item, "name", "NA") ==
                  Ops.get_string(table_item, 1, "") &&
                  Ops.get_string(item, "value", "NA") ==
                    Ops.get_string(table_item, 2, "")
              else
                match = false
              end
              match ? deep_copy(new_item) : deep_copy(item)
            end
            break
          end
        else
          break
        end
      end

      UI.CloseDialog
      nil
    end

    def Add_Blacklist_Dialog
      UI.OpenDialog(
        VBox(
          HBox(
            HWeight(
              1,
              ComboBox(
                Id(:add_blacklist_id),
                Opt(:notify),
                _("item"),
                [
                  Item(Id(:combobox_bl_wwid_id), "wwid", true),
                  Item(Id(:combobox_bl_devnode_id), "devnode"),
                  Item(Id(:combobox_bl_device_id), "device")
                ]
              )
            )
          ),
          ReplacePoint(
            Id(:replace_bl_id),
            HBox(
              TextEntry(Id(:edit_blacklist_wwid_id), Opt(:notify), _("wwid"))
            )
          ),
          HSpacing(1),
          HBox(
            PushButton(Id(:ok), Label.OKButton),
            PushButton(Id(:cancel), Opt(:default), Label.CancelButton)
          )
        )
      )
      UI.ChangeWidget(
        Id(:edit_blacklist_wwid_id),
        :ValidChars,
        build_valid_chars("wwid")
      )
      UI.SetFocus(Id(:add_blacklist_id))

      new_item = {}
      devnode_str = ""
      vendor_str = ""
      product_str = ""
      wwid_str = ""

      ret = nil
      while true
        ret = UI.UserInput
        if ret == :add_blacklist_id
          value = UI.QueryWidget(Id(:add_blacklist_id), :Value)
          if value != nil && Ops.is_symbol?(value)
            if value == :combobox_bl_device_id
              UI.ReplaceWidget(
                Id(:replace_bl_id),
                VBox(
                  TextEntry(
                    Id(:edit_blacklist_vendor_id),
                    Opt(:notify),
                    "vendor",
                    vendor_str
                  ),
                  TextEntry(
                    Id(:edit_blacklist_product_id),
                    Opt(:notify),
                    "product",
                    product_str
                  )
                )
              )
              UI.ChangeWidget(
                Id(:edit_blacklist_vendor_id),
                :ValidChars,
                build_valid_chars("vendor")
              )
              UI.ChangeWidget(
                Id(:edit_blacklist_product_id),
                :ValidChars,
                build_valid_chars("product")
              )
            elsif value == :combobox_bl_wwid_id
              UI.ReplaceWidget(
                Id(:replace_bl_id),
                VBox(
                  TextEntry(
                    Id(:edit_blacklist_wwid_id),
                    Opt(:notify),
                    "wwid",
                    wwid_str
                  )
                )
              )
              UI.ChangeWidget(
                Id(:edit_blacklist_wwid_id),
                :ValidChars,
                build_valid_chars("wwid")
              )
            elsif value == :combobox_bl_devnode_id
              UI.ReplaceWidget(
                Id(:replace_bl_id),
                VBox(
                  TextEntry(
                    Id(:edit_blacklist_devnode_id),
                    Opt(:notify),
                    "devnode",
                    devnode_str
                  )
                )
              )
              UI.ChangeWidget(
                Id(:edit_blacklist_devnode_id),
                :ValidChars,
                build_valid_chars("devnode")
              )
            end
          end
        elsif ret == :ok
          value = UI.QueryWidget(Id(:add_blacklist_id), :Value)
          if value != nil && Ops.is_symbol?(value)
            if value == :combobox_bl_device_id
              vendor = nil
              product = nil
              Ops.set(new_item, "type", "device")
              Ops.set(new_item, "name", "device")
              vendor = rm_quotes(
                Convert.to_string(
                  UI.QueryWidget(Id(:edit_blacklist_vendor_id), :Value)
                )
              )
              product = rm_quotes(
                Convert.to_string(
                  UI.QueryWidget(Id(:edit_blacklist_product_id), :Value)
                )
              )
              sub_item = { "vendor" => vendor, "product" => product }
              Ops.set(new_item, "value", sub_item)
            elsif value == :combobox_bl_wwid_id
              Ops.set(new_item, "type", "node")
              Ops.set(new_item, "name", "wwid")
              Ops.set(
                new_item,
                "value",
                rm_quotes(
                  Convert.to_string(
                    UI.QueryWidget(Id(:edit_blacklist_wwid_id), :Value)
                  )
                )
              )
            elsif value == :combobox_bl_devnode_id
              Ops.set(new_item, "type", "node")
              Ops.set(new_item, "name", "devnode")
              Ops.set(
                new_item,
                "value",
                rm_quotes(
                  Convert.to_string(
                    UI.QueryWidget(Id(:edit_blacklist_devnode_id), :Value)
                  )
                )
              )
            end
            id = "0"
            id = get_newid(@blacklist_items)
            Ops.set(new_item, "id", id)
            if check_bl_config(new_item) == true
              Multipath.config_modified = true
              @blacklist_items = Builtins.add(@blacklist_items, new_item)
              break
            end
          else
            Popup.Message(Builtins.sformat("Invalid ret: %1", ret))
          end
        elsif ret == :edit_blacklist_vendor_id
          vendor_str = rm_quotes(
            Convert.to_string(
              UI.QueryWidget(Id(:edit_blacklist_vendor_id), :Value)
            )
          )
        elsif ret == :edit_blacklist_product_id
          product_str = rm_quotes(
            Convert.to_string(
              UI.QueryWidget(Id(:edit_blacklist_product_id), :Value)
            )
          )
        elsif ret == :edit_blacklist_devnode_id
          devnode_str = rm_quotes(
            Convert.to_string(
              UI.QueryWidget(Id(:edit_blacklist_devnode_id), :Value)
            )
          )
        elsif ret == :edit_blacklist_wwid_id
          str = nil
          str = UI.QueryWidget(Id(:edit_blacklist_wwid_id), :Value)
          wwid_str = rm_quotes(Convert.to_string(str))
        else
          break
        end
      end
      UI.CloseDialog
      nil
    end

    def Blacklist_Dialog
      Wizard.SetContentsButtons(
        @caption,
        @contents,
        Ops.get_string(@HELPS, "Blacklist_help", ""),
        Label.BackButton,
        Label.OKButton
      )
      UI.ReplaceWidget(Id(:contents_replace_id), @blacklist_config)
      UI.ChangeWidget(Id(:blacklist_table_id), :Items, Build_BlacklistTable())

      ret = nil
      while true
        ret = UI.UserInput
        if @replacewidget_notify == true
          @replacewidget_notify = false
          next
        end
        if ret == :blacklist_del_id
          cur = Convert.to_integer(
            UI.QueryWidget(Id(:blacklist_table_id), :CurrentItem)
          )
          cur_item = Convert.to_term(
            UI.QueryWidget(Id(:blacklist_table_id), term(:Item, cur))
          )
          delete_blacklist_item(cur_item)
          UI.ChangeWidget(
            Id(:blacklist_table_id),
            :Items,
            Build_BlacklistTable()
          )
          next
        elsif ret == :blacklist_edit_id || ret == :blacklist_table_id
          cur = Convert.to_integer(
            UI.QueryWidget(Id(:blacklist_table_id), :CurrentItem)
          )
          cur_item = Convert.to_term(
            UI.QueryWidget(Id(:blacklist_table_id), term(:Item, cur))
          )
          Edit_Blacklist_Dialog(cur_item)
          UI.ChangeWidget(
            Id(:blacklist_table_id),
            :Items,
            Build_BlacklistTable()
          )
          UI.ChangeWidget(Id(:blacklist_table_id), :CurrentItem, cur)
          next
        elsif ret == :blacklist_add_id
          Add_Blacklist_Dialog()
          UI.ChangeWidget(
            Id(:blacklist_table_id),
            :Items,
            Build_BlacklistTable()
          )
          next
        else
          break
        end
      end
      deep_copy(ret)
    end


    def delete_blacklist_exception_item(table_item)
      table_item = deep_copy(table_item)
      @blacklist_exception_items = Builtins.filter(@blacklist_exception_items) do |e|
        match = true
        value = nil
        if Ops.get_string(table_item, 1, "NA") == "device" &&
            Ops.get_string(e, "type", "NA") == "device"
          sub_e = Ops.get_map(e, "value", {})
          if sub_e != {}
            value = Builtins.sformat(
              @device_template,
              Ops.get_string(sub_e, "vendor", "NA"),
              Ops.get_string(sub_e, "product", "NA")
            )
            match = Ops.get_string(e, "name", "NA") ==
              Ops.get_string(table_item, 1, "na") &&
              value == Ops.get_string(table_item, 2, "na")
          end
        elsif Ops.get_string(e, "type", "NA") == "node"
          match = Ops.get_string(e, "name", "NA") ==
            Ops.get_string(table_item, 1, "na") &&
            Ops.get_string(e, "value", "NA") ==
              Ops.get_string(table_item, 2, "na")
        else
          match = false
        end
        Multipath.config_modified = true if match == true
        !match
      end

      nil
    end

    def check_ble_config(item)
      item = deep_copy(item)
      prop_info = _("Illegal parameters:") + "\n"
      type_str = ""
      result = false
      ret = {}
      item_map = {}
      check_handler = nil

      type_str = Ops.get_string(item, "type", "")
      if type_str == "device"
        sub_item = Ops.get_map(item, "value", {})
        if sub_item == {}
          Popup.Message(Builtins.sformat("can not find sub_item from %1", item))
          return false
        end
        vendor_str = Ops.get_string(sub_item, "vendor", "")
        product_str = Ops.get_string(sub_item, "product", "")

        check_handler = Convert.convert(
          Ops.get(@check_handlers, :vendor),
          :from => "any",
          :to   => "map (map)"
        )
        if check_handler == nil
          Popup.Message("check handler for `vendor does not exist")
          return false
        end
        Ops.set(item_map, "vendor", vendor_str)
        ret = check_handler.call(item_map)
        result = Ops.get_boolean(ret, "result", false)
        if result == false
          prop_info = Ops.add(prop_info, Ops.get_string(ret, "info", ""))
        end

        check_handler = Convert.convert(
          Ops.get(@check_handlers, :product),
          :from => "any",
          :to   => "map (map)"
        )
        if check_handler == nil
          Popup.Message("check handler for `product does not exist")
          return false
        end
        Ops.set(item_map, "product", product_str)
        ret = check_handler.call(item_map)
        result = Ops.get_boolean(ret, "result", false)
        if result == false
          prop_info = Ops.add(prop_info, Ops.get_string(ret, "info", ""))
        end
      elsif type_str == "node"
        name_str = Ops.get_string(item, "name", "NA")
        value_str = Ops.get_string(item, "value", "")
        item_name = Builtins.symbolof(Builtins.toterm(name_str))
        check_handler = Convert.convert(
          Ops.get(@check_handlers, item_name),
          :from => "any",
          :to   => "map (map)"
        )
        if check_handler == nil
          Popup.Message(
            Builtins.sformat("check handler for %1 does not exist", item_name)
          )
          return false
        end
        Ops.set(item_map, name_str, value_str)
        ret = check_handler.call(item_map)
        result = Ops.get_boolean(ret, "result", false)
        if result == false
          prop_info = Ops.add(prop_info, Ops.get_string(ret, "info", ""))
        end
      else
        Popup.Message(
          Builtins.sformat("check_ble_config: unexpected type %1", type_str)
        )
        return false
      end

      if result == false
        Popup.Message(prop_info)
        return result
      end
      Builtins.foreach(@blacklist_exception_items) do |e|
        if e == {}
          result = true
          raise Break
        end
        next if Ops.get_string(e, "id", "") == Ops.get_string(item, "id", "na")
        if Ops.get_string(e, "type", "") == "device"
          sub_e = Ops.get_map(e, "value", {})
          sub_item = Ops.get_map(item, "value", {})
          if sub_e != {} && sub_item != {}
            if Ops.get_string(sub_item, "vendor", "NA") ==
                Ops.get_string(sub_e, "vendor", "") &&
                Ops.get_string(sub_item, "product", "NA") ==
                  Ops.get_string(sub_e, "product", "")
              result = false
              raise Break
            end
          end
        else
          if Ops.get_string(item, "name", "NA") == Ops.get_string(e, "name", "") &&
              Ops.get_string(item, "value", "NA") ==
                Ops.get_string(e, "value", "")
            result = false
            raise Break
          end
        end
      end

      Popup.Message(_("Duplicated configuration.")) if result == false

      result
    end

    def build_edit_blacklist_exception_terms(item)
      item = deep_copy(item)
      ret = Empty()
      type_str = Ops.get_string(item, "type", "")
      if type_str == "node"
        name_str = Ops.get_string(item, "name", "NA")
        item_name = Builtins.symbolof(Builtins.toterm(name_str))
        build_handler = Convert.convert(
          Ops.get(@build_term_handlers, item_name),
          :from => "any",
          :to   => "term (symbol)"
        )
        if build_handler == nil
          Popup.Message(
            Builtins.sformat(
              "build_edit_blacklist_terms: build handler for %1 does not exist",
              item_name
            )
          )
        else
          ret = VBox(
            HBox(TextEntry(Id(:blacklist_item), _("item"), "")),
            HBox(build_handler.call(:all))
          )
        end
      elsif type_str == "device"
        ret = VBox(
          HBox(TextEntry(Id(:blacklist_item), _("item"), "")),
          HBox(build_vendor_term(:all)),
          HBox(build_product_term(:all))
        )
      else
        Popup.Message(
          Builtins.sformat(
            "build_edit_blacklist_terms: unexpected type %1",
            type_str
          )
        )
      end
      deep_copy(ret)
    end

    def update_edit_blacklist_exception_items(item)
      item = deep_copy(item)
      type_str = Ops.get_string(item, "type", "NA")
      map_item = {}

      if type_str == "device"
        UI.ChangeWidget(Id(:blacklist_item), :Value, "device")
        UI.ChangeWidget(Id(:blacklist_item), :Enabled, false)

        sub_item = Ops.get_map(item, "value", {})
        if sub_item == {}
          Popup.Message(Builtins.sformat("No value in subitem `%1'", item))
          return
        end
        vendor_str = Ops.get_string(sub_item, "vendor", "")
        product_str = Ops.get_string(sub_item, "product", "")
        if Builtins.contains(@blacklist_section_items, :vendor) == false ||
            Builtins.contains(@blacklist_section_items, :product) == false
          Popup.Message("`vendor or `product is not in valid blacklist items")
          return
        end
        update_handler = Convert.convert(
          Ops.get(@update_term_handlers, :vendor),
          :from => "any",
          :to   => "void (map)"
        )
        if update_handler == nil
          Popup.Message(
            "update_edit_blacklist_items: update handler for `vendor does not exist"
          )
          return
        else
          map_item2 = {}
          Ops.set(map_item2, "vendor", vendor_str)
          update_handler.call(map_item2)
        end
        update_handler = Convert.convert(
          Ops.get(@update_term_handlers, :product),
          :from => "any",
          :to   => "void (map)"
        )
        if update_handler == nil
          Popup.Message(
            "update_edit_blacklist_items: update handler for `product does not exist"
          )
          return
        else
          map_item2 = {}
          Ops.set(map_item2, "product", product_str)
          update_handler.call(map_item2)
        end
      else
        name_str = Ops.get_string(item, "name", "NA")
        value_str = Ops.get_string(item, "value", "")
        Ops.set(map_item, name_str, value_str)
        item_name = Builtins.symbolof(Builtins.toterm(name_str))

        UI.ChangeWidget(Id(:blacklist_item), :Value, name_str)
        UI.ChangeWidget(Id(:blacklist_item), :Enabled, false)

        if Builtins.contains(@blacklist_section_items, item_name) == true
          update_handler = Convert.convert(
            Ops.get(@update_term_handlers, item_name),
            :from => "any",
            :to   => "void (map)"
          )
          if update_handler != nil
            update_handler.call(map_item)
          else
            Popup.Message(
              Builtins.sformat(
                "update_edit_blacklist_items: update handler for %1 does not exist",
                item_name
              )
            )
          end
        else
          Popup.Message(
            Builtins.sformat(
              "item %1 is not in valid blacklist items",
              item_name
            )
          )
        end
      end

      nil
    end

    def Edit_Blacklist_Exception_Dialog(table_item)
      table_item = deep_copy(table_item)
      config_item = Builtins.filter(@blacklist_exception_items) do |item|
        match = true
        if Ops.get_string(table_item, 1, "NA") == "device" &&
            Ops.get_string(item, "type", "NA") == "device"
          sub_item = Ops.get_map(item, "value", {})
          value = Builtins.sformat(
            @device_template,
            Ops.get_string(sub_item, "vendor", "NA"),
            Ops.get_string(sub_item, "product", "NA")
          )
          match = value == Ops.get_string(table_item, 2, "NA")
        elsif Ops.get_string(table_item, 1, "NA") != "device" &&
            Ops.get_string(item, "type", "NA") == "node"
          match = Ops.get_string(item, "name", "NA") ==
            Ops.get_string(table_item, 1, "na") &&
            Ops.get_string(item, "value", "NA") ==
              Ops.get_string(table_item, 2, "na")
        else
          match = false
        end
        match
      end
      cur_item = Ops.get(config_item, 0, {})
      return if cur_item == {}

      UI.OpenDialog(
        VBox(
          build_edit_blacklist_exception_terms(cur_item),
          HSpacing(1),
          HBox(
            PushButton(Id(:ok), Label.OKButton),
            PushButton(Id(:cancel), Opt(:default), Label.CancelButton)
          )
        )
      )
      update_edit_blacklist_exception_items(cur_item)

      ret = nil
      new_item = {}
      while true
        ret = UI.UserInput
        if @replacewidget_notify == true
          @replacewidget_notify = false
          next
        end

        if Builtins.contains(@blacklist_section_items, Convert.to_symbol(ret)) == true
          # do not handle, `ok will do with the value
          next
        elsif ret == :ok
          type_str = Ops.get_string(cur_item, "type", "")
          if type_str == "device"
            Ops.set(
              new_item,
              "name",
              UI.QueryWidget(Id(:blacklist_item), :Value)
            )
            Ops.set(new_item, "type", "device")
            vendor_str = rm_quotes(
              Convert.to_string(UI.QueryWidget(Id(:vendor), :Value))
            )
            product_str = rm_quotes(
              Convert.to_string(UI.QueryWidget(Id(:product), :Value))
            )
            sub_item = { "vendor" => vendor_str, "product" => product_str }
            Ops.set(new_item, "value", sub_item)
            Ops.set(new_item, "id", Ops.get_string(cur_item, "id", ""))
          elsif type_str == "node"
            name_str = Ops.get_string(cur_item, "name", "NA")
            id = Builtins.symbolof(Builtins.toterm(name_str))
            Ops.set(new_item, "type", "node")
            Ops.set(
              new_item,
              "name",
              rm_quotes(
                Convert.to_string(UI.QueryWidget(Id(:blacklist_item), :Value))
              )
            )
            Ops.set(
              new_item,
              "value",
              rm_quotes(Convert.to_string(UI.QueryWidget(Id(id), :Value)))
            )
            Ops.set(new_item, "id", Ops.get_string(cur_item, "id", ""))
          else
            Popup.Message(Builtins.sformat("Unexpected item type %1", type_str))
          end
          if check_ble_config(new_item) == true
            Multipath.config_modified = true
            @blacklist_exception_items = Builtins.maplist(
              @blacklist_exception_items
            ) do |item|
              match = true
              if Ops.get_string(table_item, 1, "") == "device" &&
                  Ops.get_string(item, "type", "") == "device"
                sub_item = Ops.get_map(item, "value", {})
                value = Builtins.sformat(
                  @device_template,
                  Ops.get_string(sub_item, "vendor", "NA"),
                  Ops.get_string(sub_item, "product", "NA")
                )
                match = Ops.get_string(item, "name", "NA") ==
                  Ops.get_string(table_item, 1, "") &&
                  value == Ops.get_string(table_item, 2, "")
              elsif Ops.get_string(table_item, 1, "") != "device" &&
                  Ops.get_string(item, "type", "") == "node"
                match = Ops.get_string(item, "name", "NA") ==
                  Ops.get_string(table_item, 1, "") &&
                  Ops.get_string(item, "value", "NA") ==
                    Ops.get_string(table_item, 2, "")
              else
                match = false
              end
              match ? deep_copy(new_item) : deep_copy(item)
            end
            break
          end
        else
          break
        end
      end

      UI.CloseDialog
      nil
    end


    def Add_Blacklist_Exception_Dialog
      UI.OpenDialog(
        VBox(
          HBox(
            HWeight(
              1,
              ComboBox(
                Id(:add_blacklist_id),
                Opt(:notify),
                _("item"),
                [
                  Item(Id(:combobox_bl_wwid_id), "wwid", true),
                  Item(Id(:combobox_bl_devnode_id), "devnode"),
                  Item(Id(:combobox_bl_device_id), "device")
                ]
              )
            )
          ),
          ReplacePoint(
            Id(:replace_bl_id),
            HBox(
              TextEntry(Id(:edit_blacklist_wwid_id), Opt(:notify), _("wwid"))
            )
          ),
          HSpacing(1),
          HBox(
            PushButton(Id(:ok), Label.OKButton),
            PushButton(Id(:cancel), Opt(:default), Label.CancelButton)
          )
        )
      )
      UI.ChangeWidget(
        Id(:edit_blacklist_wwid_id),
        :ValidChars,
        build_valid_chars("wwid")
      )
      UI.SetFocus(Id(:add_blacklist_id))

      new_item = {}
      devnode_str = ""
      vendor_str = ""
      product_str = ""
      wwid_str = ""

      ret = nil
      while true
        ret = UI.UserInput
        if ret == :add_blacklist_id
          value = UI.QueryWidget(Id(:add_blacklist_id), :Value)
          if value != nil && Ops.is_symbol?(value)
            if value == :combobox_bl_device_id
              UI.ReplaceWidget(
                Id(:replace_bl_id),
                VBox(
                  TextEntry(
                    Id(:edit_blacklist_vendor_id),
                    Opt(:notify),
                    "vendor",
                    vendor_str
                  ),
                  TextEntry(
                    Id(:edit_blacklist_product_id),
                    Opt(:notify),
                    "product",
                    product_str
                  )
                )
              )
              UI.ChangeWidget(
                Id(:edit_blacklist_vendor_id),
                :ValidChars,
                build_valid_chars("vendor")
              )
              UI.ChangeWidget(
                Id(:edit_blacklist_product_id),
                :ValidChars,
                build_valid_chars("product")
              )
            elsif value == :combobox_bl_wwid_id
              UI.ReplaceWidget(
                Id(:replace_bl_id),
                VBox(
                  TextEntry(
                    Id(:edit_blacklist_wwid_id),
                    Opt(:notify),
                    "wwid",
                    wwid_str
                  )
                )
              )
              UI.ChangeWidget(
                Id(:edit_blacklist_wwid_id),
                :ValidChars,
                build_valid_chars("wwid")
              )
            elsif value == :combobox_bl_devnode_id
              UI.ReplaceWidget(
                Id(:replace_bl_id),
                VBox(
                  TextEntry(
                    Id(:edit_blacklist_devnode_id),
                    Opt(:notify),
                    "devnode",
                    devnode_str
                  )
                )
              )
              UI.ChangeWidget(
                Id(:edit_blacklist_devnode_id),
                :ValidChars,
                build_valid_chars("devnode")
              )
            end
          end
        elsif ret == :ok
          value = UI.QueryWidget(Id(:add_blacklist_id), :Value)
          if value != nil && Ops.is_symbol?(value)
            if value == :combobox_bl_device_id
              vendor = nil
              product = nil
              Ops.set(new_item, "type", "device")
              Ops.set(new_item, "name", "device")
              vendor = rm_quotes(
                Convert.to_string(
                  UI.QueryWidget(Id(:edit_blacklist_vendor_id), :Value)
                )
              )
              product = rm_quotes(
                Convert.to_string(
                  UI.QueryWidget(Id(:edit_blacklist_product_id), :Value)
                )
              )
              sub_item = { "vendor" => vendor, "product" => product }
              Ops.set(new_item, "value", sub_item)
            elsif value == :combobox_bl_wwid_id
              Ops.set(new_item, "type", "node")
              Ops.set(new_item, "name", "wwid")
              Ops.set(
                new_item,
                "value",
                rm_quotes(
                  Convert.to_string(
                    UI.QueryWidget(Id(:edit_blacklist_wwid_id), :Value)
                  )
                )
              )
            elsif value == :combobox_bl_devnode_id
              Ops.set(new_item, "type", "node")
              Ops.set(new_item, "name", "devnode")
              Ops.set(
                new_item,
                "value",
                rm_quotes(
                  Convert.to_string(
                    UI.QueryWidget(Id(:edit_blacklist_devnode_id), :Value)
                  )
                )
              )
            end
            id = "0"
            id = get_newid(@blacklist_exception_items)
            Ops.set(new_item, "id", id)
            if check_ble_config(new_item) == true
              Multipath.config_modified = true
              @blacklist_exception_items = Builtins.add(
                @blacklist_exception_items,
                new_item
              )
              break
            end
          else
            Popup.Message(Builtins.sformat("Invalid ret: %1", ret))
          end
        elsif ret == :edit_blacklist_vendor_id
          vendor_str = rm_quotes(
            Convert.to_string(
              UI.QueryWidget(Id(:edit_blacklist_vendor_id), :Value)
            )
          )
        elsif ret == :edit_blacklist_product_id
          product_str = rm_quotes(
            Convert.to_string(
              UI.QueryWidget(Id(:edit_blacklist_product_id), :Value)
            )
          )
        elsif ret == :edit_blacklist_devnode_id
          devnode_str = rm_quotes(
            Convert.to_string(
              UI.QueryWidget(Id(:edit_blacklist_devnode_id), :Value)
            )
          )
        elsif ret == :edit_blacklist_wwid_id
          str = nil
          str = UI.QueryWidget(Id(:edit_blacklist_wwid_id), :Value)
          wwid_str = rm_quotes(Convert.to_string(str))
        else
          break
        end
      end
      UI.CloseDialog
      nil
    end


    def Blacklist_Exception_Dialog
      Wizard.SetContentsButtons(
        @caption,
        @contents,
        Ops.get_string(@HELPS, "Blacklist_Exception_help", ""),
        Label.BackButton,
        Label.OKButton
      )
      UI.ReplaceWidget(Id(:contents_replace_id), @blacklist_exception_config)
      UI.ChangeWidget(
        Id(:blacklist_table_id),
        :Items,
        Build_BlacklistException_Table()
      )

      ret = nil
      while true
        ret = UI.UserInput
        if ret == :blacklist_del_id
          cur = Convert.to_integer(
            UI.QueryWidget(Id(:blacklist_table_id), :CurrentItem)
          )
          cur_item = Convert.to_term(
            UI.QueryWidget(Id(:blacklist_table_id), term(:Item, cur))
          )
          delete_blacklist_exception_item(cur_item)
          UI.ChangeWidget(
            Id(:blacklist_table_id),
            :Items,
            Build_BlacklistException_Table()
          )
          next
        elsif ret == :blacklist_edit_id || ret == :blacklist_table_id
          cur = Convert.to_integer(
            UI.QueryWidget(Id(:blacklist_table_id), :CurrentItem)
          )
          cur_item = Convert.to_term(
            UI.QueryWidget(Id(:blacklist_table_id), term(:Item, cur))
          )
          Edit_Blacklist_Exception_Dialog(cur_item)
          UI.ChangeWidget(
            Id(:blacklist_table_id),
            :Items,
            Build_BlacklistException_Table()
          )
          UI.ChangeWidget(Id(:blacklist_table_id), :CurrentItem, cur)
          next
        elsif ret == :blacklist_add_id
          Add_Blacklist_Exception_Dialog()
          UI.ChangeWidget(
            Id(:blacklist_table_id),
            :Items,
            Build_BlacklistException_Table()
          )
          next
        else
          break
        end
      end
      deep_copy(ret)
    end

    def build_device_details
      confs_term = VBox(Empty())
      counter = 0
      item_per_line = 2
      line = HBox(Empty())

      Builtins.foreach(@device_detail_items) do |item_symbol|
        build_handler = Convert.convert(
          Ops.get(@build_term_handlers, item_symbol),
          :from => "any",
          :to   => "term (symbol)"
        )
        if build_handler == nil
          Popup.Message(
            Builtins.sformat(
              "build term handler for %1 does not exist",
              item_symbol
            )
          )
          next
        end
        line = Builtins.add(line, HWeight(1, build_handler.call(:all)))
        counter = Ops.add(counter, 1)
        if Ops.modulo(counter, item_per_line) == 0
          confs_term = Builtins.add(confs_term, line)
          line = HBox(Empty())
        end
      end
      deep_copy(confs_term)
    end

    def update_device_details(item)
      item = deep_copy(item)
      Builtins.foreach(@device_detail_items) do |item_symbol|
        update_handler = Convert.convert(
          Ops.get(@update_term_handlers, item_symbol),
          :from => "any",
          :to   => "void (map)"
        )
        if update_handler == nil
          Popup.Message(
            Builtins.sformat(
              "update term handler for %1 does not exist",
              item_symbol
            )
          )
          next
        end
        update_handler.call(item)
      end

      nil
    end

    # check if user input is legal, and popup necessary information
    def check_dv_config(item)
      item = deep_copy(item)
      result = true
      prop_info = _("Illegal parameters:\n")

      Builtins.foreach(@device_brief_items) do |item_name|
        ret = {}
        check_handler = Convert.convert(
          Ops.get(@check_handlers, item_name),
          :from => "any",
          :to   => "map (map)"
        )
        if check_handler != nil
          ret = check_handler.call(item)
          if ret == nil
            Popup.Message(
              Builtins.sformat(
                "check handler for %1 is not implemented yet",
                item_name
              )
            )
          elsif Ops.get_boolean(ret, "result", false) == false
            prop_info = Ops.add(prop_info, Ops.get_string(ret, "info", ""))
            result = false
          end
        else
          Popup.Message(
            Builtins.sformat("check handler does not exist for %1", item_name)
          )
        end
      end

      if result == false
        Popup.Message(prop_info)
        return result
      end

      Builtins.foreach(@device_detail_items) do |item_name|
        ret = {}
        check_handler = Convert.convert(
          Ops.get(@check_handlers, item_name),
          :from => "any",
          :to   => "map (map)"
        )
        if check_handler != nil
          ret = check_handler.call(item)
          if ret == nil
            Popup.Message(
              Builtins.sformat(
                "check handler for %1 is not implemented yet",
                item_name
              )
            )
          elsif Ops.get_boolean(ret, "result", false) == false
            prop_info = Ops.add(prop_info, Ops.get_string(ret, "info", ""))
            result = false
          end
        else
          Popup.Message(
            Builtins.sformat("check handler does not exist for %1", item_name)
          )
        end
      end

      if result == false
        Popup.Message(prop_info)
        return result
      end

      # duplicated configuraton checking
      Builtins.foreach(@multipaths_items) do |e|
        if Ops.get_string(e, "id", "NA") != Ops.get_string(item, "id", "na") &&
            Ops.get_string(e, "wwid", "NA") ==
              Ops.get_string(item, "wwid", "na")
          prop_info = _("Duplicated configuration.")
          Popup.Message(prop_info)
          result = false
          raise Break
        end
      end

      # duplicated configuraton checking
      vendor_str = Ops.get_string(item, "vendor", "")
      product_str = Ops.get_string(item, "product", "")
      Builtins.foreach(@devices_items) do |e|
        if Ops.get_string(e, "id", "NA") != Ops.get_string(item, "id", "na") &&
            vendor_str == Ops.get_string(e, "vendor", "NA") &&
            product_str == Ops.get_string(e, "product", "NA")
          prop_info = _("Duplicated configuration")
          Popup.Message(prop_info)
          result = false
          raise Break
        end
      end
      result
    end


    #     if table_item == nil, means add a new item
    def Edit_Devices_Dialog(table_item)
      table_item = deep_copy(table_item)
      cur_item = {}
      if table_item != nil
        config_item = Builtins.filter(@devices_items) do |item|
          match = Ops.get_string(item, "vendor", "NA") ==
            Ops.get_string(table_item, 1, "na") &&
            Ops.get_string(item, "product", "NA") ==
              Ops.get_string(table_item, 2, "na")
          match
        end
        cur_item = Ops.get(config_item, 0)
        return nil if cur_item == nil
      end

      # used for store undecided input
      temp_cur_item = deep_copy(cur_item)
      Ops.set(
        temp_cur_item,
        "id",
        cur_item == {} ?
          get_newid(@devices_items) :
          Ops.get_string(cur_item, "id", "0")
      )

      devices_item_edit = VBox(
        HWeight(1, HBox(build_vendor_term(:all))),
        HWeight(1, HBox(build_product_term(:all))),
        HWeight(1, HBox(build_product_blacklist_term(:all))),
        VBox(
          ReplacePoint(
            Id(:replace_devices_id),
            VBox(
              Left(
                HBox(
                  CheckBox(
                    Id(:show_details_id),
                    Opt(:notify),
                    _("Show Details"),
                    false
                  )
                )
              )
            )
          )
        )
      )
      UI.OpenDialog(
        VBox(
          devices_item_edit,
          HSpacing(1),
          HBox(
            PushButton(Id(:ok), Opt(:default), Label.OKButton),
            PushButton(Id(:cancel), Label.CancelButton)
          )
        )
      )
      update_vendor_term(temp_cur_item)
      update_product_term(temp_cur_item)
      update_product_blacklist_term(temp_cur_item)
      UI.SetFocus(Id(:product_blacklist))
      @temp_string_values = {}

      ret = nil
      while true
        ret = UI.UserInput
        if @replacewidget_notify == true
          @replacewidget_notify = false
          next
        end
        if ret == :show_details_id
          checked = Convert.to_boolean(
            UI.QueryWidget(Id(:show_details_id), :Value)
          )
          if checked == true
            UI.ReplaceWidget(
              Id(:replace_devices_id),
              VBox(
                Left(
                  HBox(
                    CheckBox(
                      Id(:show_details_id),
                      Opt(:notify),
                      _("Show Details"),
                      true
                    )
                  )
                ),
                build_device_details
              )
            )
            update_device_details(temp_cur_item)
          else
            UI.ReplaceWidget(
              Id(:replace_devices_id),
              VBox(
                Left(
                  HBox(
                    CheckBox(
                      Id(:show_details_id),
                      Opt(:notify),
                      _("Show Details"),
                      false
                    )
                  )
                )
              )
            )
          end
        elsif Builtins.contains(@device_detail_items, Convert.to_symbol(ret)) == true ||
            Builtins.contains(@device_brief_items, Convert.to_symbol(ret)) == true
          device_handler = Convert.convert(
            Ops.get(@default_item_handlers, Convert.to_symbol(ret)),
            :from => "any",
            :to   => "map (map)"
          )
          if device_handler != nil
            temp_cur_item = device_handler.call(temp_cur_item)
          else
            Popup.Message(
              Builtins.sformat(
                "can not find handler for %1",
                Convert.to_symbol(ret)
              )
            )
          end
        elsif ret == :ok
          Ops.set(
            temp_cur_item,
            "vendor",
            rm_quotes(Ops.get_string(temp_cur_item, "vendor", ""))
          )
          Ops.set(
            temp_cur_item,
            "product",
            rm_quotes(Ops.get_string(temp_cur_item, "product", ""))
          )
          if check_dv_config(temp_cur_item) == true
            Multipath.config_modified = true
            cur_item = deep_copy(temp_cur_item)
            if table_item != nil
              @devices_items = Builtins.maplist(@devices_items) do |item|
                if Ops.get_string(table_item, 1, "NA") ==
                    Ops.get_string(item, "vendor", "na") &&
                    Ops.get_string(table_item, 2, "NA") ==
                      Ops.get_string(item, "product", "na")
                  next deep_copy(cur_item)
                else
                  next deep_copy(item)
                end
              end
            else
              @devices_items = Builtins.add(@devices_items, cur_item)
            end
            break
          end
        else
          break
        end
      end

      UI.CloseDialog
      nil
    end




    def Devices_Dialog
      Wizard.SetContentsButtons(
        @caption,
        @contents,
        Ops.get_string(@HELPS, "Devices_help", ""),
        Label.BackButton,
        Label.OKButton
      )
      UI.ReplaceWidget(Id(:contents_replace_id), @devices_config)
      UI.ChangeWidget(Id(:devices_table_id), :Items, Build_DevicesTable())

      ret = nil
      while true
        ret = UI.UserInput
        if ret == :devices_del_id
          cur = Convert.to_integer(
            UI.QueryWidget(Id(:devices_table_id), :CurrentItem)
          )
          cur_item = Convert.to_term(
            UI.QueryWidget(Id(:devices_table_id), term(:Item, cur))
          )
          @devices_items = Builtins.filter(@devices_items) do |item|
            match = Ops.get_string(item, "vendor", "NA") ==
              Ops.get_string(cur_item, 1, "na") &&
              Ops.get_string(item, "product", "NA") ==
                Ops.get_string(cur_item, 2, "na")
            Multipath.config_modified = true if match == true
            !match
          end
          UI.ChangeWidget(Id(:devices_table_id), :Items, Build_DevicesTable())
          next
        elsif ret == :devices_edit_id || ret == :devices_table_id
          cur = Convert.to_integer(
            UI.QueryWidget(Id(:devices_table_id), :CurrentItem)
          )
          cur_item = Convert.to_term(
            UI.QueryWidget(Id(:devices_table_id), term(:Item, cur))
          )
          Edit_Devices_Dialog(cur_item)
          UI.ChangeWidget(Id(:devices_table_id), :Items, Build_DevicesTable())
          UI.ChangeWidget(Id(:devices_table_id), :CurrentItem, cur)
          next
        elsif ret == :devices_add_id
          cur = Convert.to_integer(
            UI.QueryWidget(Id(:devices_table_id), :CurrentItem)
          )
          Edit_Devices_Dialog(nil)
          UI.ChangeWidget(Id(:devices_table_id), :Items, Build_DevicesTable())
          UI.ChangeWidget(Id(:devices_table_id), :CurrentItem, cur)
          next
        else
          break
        end
      end
      deep_copy(ret)
    end


    def Update_Service_Status
      ret = 0
      if Mode.normal && Stage.normal
        ret = Service.Status("multipathd")
      else
        ret = Convert.to_integer(
          SCR.Execute(
            path(".target.bash"),
            "/bin/ps -A -o comm | grep -q multipathd"
          )
        )
      end
      if ret == 0
        UI.ChangeWidget(Id(:stop_multipath), :Value, false)
        UI.ChangeWidget(Id(:start_multipath), :Value, true)
        @service_status = 1
      else
        UI.ChangeWidget(Id(:stop_multipath), :Value, true)
        UI.ChangeWidget(Id(:start_multipath), :Value, false)
        @service_status = 0
      end

      ret = Convert.to_integer(
        SCR.Execute(path(".target.bash"), "/sbin/multipath -l")
      )
      info = ""
      if ret == 127
        info = _("Can not find /sbin/multipath") 
        # "multipath -l" will display usable information even returns 1 to bash
      elsif ret == 0 || ret == 1
        result = {}
        result = Convert.to_map(
          SCR.Execute(path(".target.bash_output"), "/sbin/multipath -l")
        )
        info = Ops.get_string(
          result,
          "stdout",
          "Failed to run /sbin/multipath\n"
        )
      else
        info = "Failed to run multipath, error number:\n"
        info = Ops.add(info, Builtins.sformat("%1\n", ret))
      end
      # "multipath -l" may returns "" to bash
      info = "No multipath information found\n" if Builtins.size(info) == 0
      UI.ChangeWidget(Id(:status_summary_id), :Value, info)

      nil
    end

    def Start_Service
      return if @service_status == 1
      prop_info = _("Use multipath failed:") + "\n"

      if Mode.normal && Stage.normal
        ret = Service.Enable("multipathd")
        if ret == false
          prop_info = Ops.add(
            Ops.add(prop_info, _("* Cannot enable multipathd.")),
            "\n"
          )
          Popup.Message(prop_info)
          Update_Service_Status()
          return
        end
        ret = Service.Start("multipathd")
        if ret == false
          prop_info = Ops.add(
            Ops.add(prop_info, _("* Cannot start multipathd.")),
            "\n"
          )
          Popup.Message(prop_info)
          Update_Service_Status()
          return
        end
      else
        # There is no multipathd service, rely on Y2Storage
        Y2Storage::StorageManager.instance.activate
      end

      @service_status = 1
      Update_Service_Status()

      nil
    end

    def Stop_Service
      return if @service_status == 0
      prop_info = _("Do not use multipath failed:") + "\n"

      if Mode.normal && Stage.normal
        ret = Service.Stop("multipathd")
        if ret == false
          prop_info = Ops.add(
            Ops.add(prop_info, _("* Cannot stop multipath.")),
            "\n"
          )
          Popup.Message(prop_info)
          Update_Service_Status()
          return
        end
        ret = Service.Disable("multipathd")
        if ret == false
          prop_info = Ops.add(
            Ops.add(prop_info, _("* Cannot disable multipathd.")),
            "\n"
          )
          Popup.Message(prop_info)
          Update_Service_Status()
          return
        end
      else
        # There is no multipathd service, rely on Y2Storage
        Y2Storage::StorageManager.instance.deactivate
      end

      @service_status = 0
      Update_Service_Status()

      nil
    end
  end
end
