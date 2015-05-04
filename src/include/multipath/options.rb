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

# File:	modules/defaults_options.ycp
# Package:	Configuration of multipath
# Summary:	global default option stuffs for multipath configuration
# Authors:	Coly Li <coyli@suse.de>
#
# $Id: options.ycp,v 1.49 2007/01/22 03:25:16 coly Exp $
#
# Global default option sutffs for multipath configurations, this file is included
# by complex.ycp.
# The default options can be used in defauts section, and other sections.
module Yast
  module MultipathOptionsInclude
    def initialize_multipath_options(include_target)
      Yast.import "UI"

      Yast.import "Popup"

      textdomain "multipath"

      # hold temporary customized string value of combobox
      @temp_string_values = {}
      @replacewidget_notify = false

      @optlabel = {
        "polling_interval"     => "polling_interval",
        "udev_dir"             => "udev_dir",
        "selector"             => "selector",
        "path_selector"        => "path_selector",
        "path_grouping_policy" => "path_grouping_policy",
        "getuid_callout"       => "getuid_callout",
        "prio_callout"         => "prio_callout",
        "features"             => "features",
        "path_checker"         => "path_checker",
        "failback"             => "failback",
        "rr_min_io"            => "rr_min_io",
        "rr_weight"            => "rr_weight",
        "no_path_retry"        => "no_path_retry",
        "user_friendly_names"  => "user_friendly_names",
        "wwid"                 => "wwid",
        "devnode"              => "devnode",
        "alias"                => "alias",
        "vendor"               => "vendor",
        "product"              => "product",
        "product_blacklist"    => "product_blacklist",
        "hardware_handler"     => "hardware_handler"
      }



      @polling_interval_opts = {
        "type"  => "textentry",
        "entry" => {
          "name" => Ops.get_string(@optlabel, "polling_interval", "NA"),
          "id"   => :polling_interval
        }
      }

      @udev_dir_opts = {
        "type"  => "textentry",
        "entry" => {
          "name" => Ops.get_string(@optlabel, "udev_dir", "NA"),
          "id"   => :udev_dir
        }
      }

      @selector_opts = {
        "type" => "combobox",
        "list" => [
          {
            "name"   => "round_robin",
            "id"     => :round_robin,
            "optstr" => "\"round-robin 0\""
          },
          { "name" => "none", "id" => :none, "optstr" => "" }
        ]
      }

      @path_selector_opts = {
        "type" => "combobox",
        "list" => [
          {
            "name"   => "round_robin",
            "id"     => :round_robin,
            "optstr" => "\"round-robin 0\""
          },
         {
            "name"   => "service_time",
            "id"     => :service_time,
            "optstr" => "\"service-time 0\""
          },
         {
            "name"   => "queue_length",
            "id"     => :queue_length,
            "optstr" => "\"queue-length 0\""
          },
          { "name" => "none", "id" => :none, "optstr" => "" }
        ]
      }

      @path_gp_opts = {
        "type" => "combobox",
        "list" => [
          { "name" => "failover", "id" => :failover, "optstr" => "failover" },
          { "name" => "multibus", "id" => :multibus, "optstr" => "multibus" },
          {
            "name"   => "group_by_serial",
            "id"     => :group_by_serial,
            "optstr" => "group_by_serial"
          },
          {
            "name"   => "group_by_prio",
            "id"     => :group_by_prio,
            "optstr" => "group_by_prio"
          },
          {
            "name"   => "group_by_node_name",
            "id"     => :group_by_node_name,
            "optstr" => "group_by_node_name"
          },
          { "name" => "none", "id" => :none, "optstr" => "" }
        ]
      }

      @getuid_callout_opts = {
        "type" => "combobox",
        "list" => [
          {
            "name"   => "default",
            "id"     => :default,
            "optstr" => "\"/sbin/scsi_id -g -u -s\""
          },
          {
            "name"   => "customized_str",
            "id"     => :customized_str,
            "optstr" => "(callout path string)"
          }
        ]
      }

      @prio_callout_opts = {
        "type" => "combobox",
        "list" => [
          {
            "name"   => "prio_emc",
            "id"     => :prio_emc,
            "optstr" => "\"mpath_prio_emc /dev/%n\""
          },
          {
            "name"   => "prio_alua",
            "id"     => :prio_alua,
            "optstr" => "\"mpath_prio_alua /dev/%n\""
          },
          {
            "name"   => "prio_netapp",
            "id"     => :prio_netapp,
            "optstr" => "\"mpath_prio_netapp /dev/%n\""
          },
          {
            "name"   => "prio_tpc",
            "id"     => :prio_tpc,
            "optstr" => "\"mpath_prio_tpc /dev/%n\""
          },
          {
            "name"   => "prio_hp_sw",
            "id"     => :prio_hp_sw,
            "optstr" => "\"mpath_prio_hp_sw /dev/%n\""
          },
          {
            "name"   => "prio_hds_mod",
            "id"     => :prio_hds_mod,
            "optstr" => "\"mpath_prio_hds_modular %b\""
          },
          { "name" => "none", "id" => :none, "optstr" => "" }
        ]
      }

      @features_opts = {
        "type" => "combobox",
        "list" => [
          { "name" => "0", "id" => :zero, "optstr" => "0" },
          {
            "name"   => "queue_if_no_path",
            "id"     => :queue_if_no_path,
            "optstr" => "\"1 queue_if_no_path\""
          },
          { "name" => "none", "id" => :none, "optstr" => "" }
        ]
      }

      @path_checker_opts = {
        "type" => "combobox",
        "list" => [
          {
            "name"   => "readsector0",
            "id"     => :readsector0,
            "optstr" => "readsector0"
          },
          { "name" => "tur", "id" => :tur, "optstr" => "tur" },
          {
            "name"   => "emc_clariion",
            "id"     => :emc_clariion,
            "optstr" => "emc_clariion"
          },
          { "name" => "hp_sw", "id" => :hp_sw, "optstr" => "hp_sw" },
          { "name" => "rdac", "id" => :rdac, "optstr" => "rdac" },
          { "name" => "directio", "id" => :directio, "optstr" => "directio" },
          { "name" => "none", "id" => :none, "optstr" => "" }
        ]
      }

      @failback_opts = {
        "type" => "combobox",
        "list" => [
          { "name" => "manual", "id" => :manual, "optstr" => "manual" },
          { "name" => "immediate", "id" => :immediate, "optstr" => "immediate" },
          {
            "name"   => "customized_str",
            "id"     => :customized_str,
            "optstr" => "(number > 0)"
          }
        ]
      }

      @rr_min_io_opts = {
        "type"  => "textentry",
        "entry" => {
          "name" => Ops.get_string(@optlabel, "rr_min_io", "NA"),
          "id"   => :rr_min_io
        }
      }

      @rr_weight_opts = {
        "type" => "combobox",
        "list" => [
          {
            "name"   => "priorities",
            "id"     => :priorities,
            "optstr" => "priorities"
          },
          { "name" => "uniform", "id" => :uniform, "optstr" => "uniform" },
          { "name" => "none", "id" => :none, "optstr" => "" }
        ]
      }

      @no_path_retry_opts = {
        "type" => "combobox",
        "list" => [
          { "name" => "fail", "id" => :fail, "optstr" => "fail" },
          { "name" => "queue", "id" => :queue, "optstr" => "queue" },
          {
            "name"   => "customized_str",
            "id"     => :customized_str,
            "optstr" => "(number >= 0)"
          }
        ]
      }

      @user_friendly_names_opts = {
        "type" => "combobox",
        "list" => [
          { "name" => "yes", "id" => :yes, "optstr" => "yes" },
          { "name" => "no", "id" => :no, "optstr" => "no" },
          { "name" => "none", "id" => :none, "optstr" => "" }
        ]
      }

      @wwid_opts = {
        "type"  => "textentry",
        "entry" => {
          "name" => Ops.get_string(@optlabel, "wwid", "NA"),
          "id"   => :wwid
        }
      }

      @devnode_opts = {
        "type"  => "textentry",
        "entry" => {
          "name" => Ops.get_string(@optlabel, "devnode", "NA"),
          "id"   => :devnode
        }
      }

      @alias_opts = {
        "type"  => "textentry",
        "entry" => {
          "name" => Ops.get_string(@optlabel, "alias", "NA"),
          "id"   => :alias
        }
      }

      @vendor_opts = {
        "type"  => "textentry",
        "entry" => {
          "name" => Ops.get_string(@optlabel, "vendor", "NA"),
          "id"   => :vendor
        }
      }

      @product_opts = {
        "type"  => "textentry",
        "entry" => {
          "name" => Ops.get_string(@optlabel, "product", "NA"),
          "id"   => :product
        }
      }

      @product_blacklist_opts = {
        "type"  => "textentry",
        "entry" => {
          "name" => Ops.get_string(@optlabel, "product_blacklist", "NA"),
          "id"   => :product_blacklist
        }
      }

      @hardware_handler_opts = {
        "type"  => "textentry",
        "entry" => {
          "name" => Ops.get_string(@optlabel, "hardware_handler", "NA"),
          "id"   => :hardware_handler
        }
      }

      @build_term_handlers = {
        :polling_interval     => fun_ref(
          method(:build_polling_interval_term),
          "term (symbol)"
        ),
        :udev_dir             => fun_ref(
          method(:build_udev_dir_term),
          "term (symbol)"
        ),
        :selector             => fun_ref(
          method(:build_selector_term),
          "term (symbol)"
        ),
        :path_selector        => fun_ref(
          method(:build_path_selector_term),
          "term (symbol)"
        ),
        :path_grouping_policy => fun_ref(
          method(:build_path_gp_term),
          "term (symbol)"
        ),
        :getuid_callout       => fun_ref(
          method(:build_getuid_callout_term),
          "term (symbol)"
        ),
        :prio_callout         => fun_ref(
          method(:build_prio_callout_term),
          "term (symbol)"
        ),
        :features             => fun_ref(
          method(:build_features_term),
          "term (symbol)"
        ),
        :path_checker         => fun_ref(
          method(:build_path_checker_term),
          "term (symbol)"
        ),
        :failback             => fun_ref(
          method(:build_failback_term),
          "term (symbol)"
        ),
        :rr_min_io            => fun_ref(
          method(:build_rr_min_io_term),
          "term (symbol)"
        ),
        :rr_weight            => fun_ref(
          method(:build_rr_weight_term),
          "term (symbol)"
        ),
        :no_path_retry        => fun_ref(
          method(:build_no_path_retry_term),
          "term (symbol)"
        ),
        :user_friendly_names  => fun_ref(
          method(:build_user_friendly_names_term),
          "term (symbol)"
        ),
        :wwid                 => fun_ref(
          method(:build_wwid_term),
          "term (symbol)"
        ),
        :devnode              => fun_ref(
          method(:build_devnode_term),
          "term (symbol)"
        ),
        :alias                => fun_ref(
          method(:build_alias_term),
          "term (symbol)"
        ),
        :vendor               => fun_ref(
          method(:build_vendor_term),
          "term (symbol)"
        ),
        :product              => fun_ref(
          method(:build_product_term),
          "term (symbol)"
        ),
        :product_blacklist    => fun_ref(
          method(:build_product_blacklist_term),
          "term (symbol)"
        ),
        :hardware_handler     => fun_ref(
          method(:build_hardware_handler_term),
          "term (symbol)"
        )
      }

      @update_term_handlers = {
        :polling_interval     => fun_ref(
          method(:update_polling_interval_term),
          "void (map)"
        ),
        :udev_dir             => fun_ref(
          method(:update_udev_dir_term),
          "void (map)"
        ),
        :selector             => fun_ref(
          method(:update_selector_term),
          "void (map)"
        ),
        :path_selector        => fun_ref(
          method(:update_path_selector_term),
          "void (map)"
        ),
        :path_grouping_policy => fun_ref(
          method(:update_path_gp_term),
          "void (map)"
        ),
        :getuid_callout       => fun_ref(
          method(:update_getuid_callout_term),
          "void (map)"
        ),
        :prio_callout         => fun_ref(
          method(:update_prio_callout_term),
          "void (map)"
        ),
        :features             => fun_ref(
          method(:update_features_term),
          "void (map)"
        ),
        :path_checker         => fun_ref(
          method(:update_path_checker_term),
          "void (map)"
        ),
        :failback             => fun_ref(
          method(:update_failback_term),
          "void (map)"
        ),
        :rr_min_io            => fun_ref(
          method(:update_rr_min_io_term),
          "void (map)"
        ),
        :rr_weight            => fun_ref(
          method(:update_rr_weight_term),
          "void (map)"
        ),
        :no_path_retry        => fun_ref(
          method(:update_no_path_retry_term),
          "void (map)"
        ),
        :user_friendly_names  => fun_ref(
          method(:update_user_friendly_names_term),
          "void (map)"
        ),
        :wwid                 => fun_ref(
          method(:update_wwid_term),
          "void (map)"
        ),
        :devnode              => fun_ref(
          method(:update_devnode_term),
          "void (map)"
        ),
        :alias                => fun_ref(
          method(:update_alias_term),
          "void (map)"
        ),
        :vendor               => fun_ref(
          method(:update_vendor_term),
          "void (map)"
        ),
        :product              => fun_ref(
          method(:update_product_term),
          "void (map)"
        ),
        :product_blacklist    => fun_ref(
          method(:update_product_blacklist_term),
          "void (map)"
        ),
        :hardware_handler     => fun_ref(
          method(:update_hardware_handler_term),
          "void (map)"
        )
      }

      @default_item_handlers = {
        :polling_interval     => fun_ref(
          method(:polling_interval_handler),
          "map (map)"
        ),
        :udev_dir             => fun_ref(method(:udev_dir_handler), "map (map)"),
        :selector             => fun_ref(method(:selector_handler), "map (map)"),
        :path_selector        => fun_ref(
          method(:path_selector_handler),
          "map (map)"
        ),
        :path_grouping_policy => fun_ref(method(:path_gp_handler), "map (map)"),
        :getuid_callout       => fun_ref(
          method(:getuid_callout_handler),
          "map (map)"
        ),
        :prio_callout         => fun_ref(
          method(:prio_callout_handler),
          "map (map)"
        ),
        :features             => fun_ref(method(:features_handler), "map (map)"),
        :path_checker         => fun_ref(
          method(:path_checker_handler),
          "map (map)"
        ),
        :failback             => fun_ref(method(:failback_handler), "map (map)"),
        :rr_min_io            => fun_ref(
          method(:rr_min_io_handler),
          "map (map)"
        ),
        :rr_weight            => fun_ref(
          method(:rr_weight_handler),
          "map (map)"
        ),
        :no_path_retry        => fun_ref(
          method(:no_path_retry_handler),
          "map (map)"
        ),
        :user_friendly_names  => fun_ref(
          method(:user_friendly_names_handler),
          "map (map)"
        ),
        :wwid                 => fun_ref(method(:wwid_handler), "map (map)"),
        :devnode              => fun_ref(method(:devnode_handler), "map (map)"),
        :alias                => fun_ref(method(:alias_handler), "map (map)"),
        :vendor               => fun_ref(method(:vendor_handler), "map (map)"),
        :product              => fun_ref(method(:product_handler), "map (map)"),
        :product_blacklist    => fun_ref(
          method(:product_blacklist_handler),
          "map (map)"
        ),
        :hardware_handler     => fun_ref(
          method(:hardware_handler_handler),
          "map (map)"
        )
      }

      @check_handlers = {
        :polling_interval     => fun_ref(
          method(:check_polling_interval),
          "map (map)"
        ),
        :udev_dir             => fun_ref(method(:check_udev_dir), "map (map)"),
        :selector             => fun_ref(method(:check_selector), "map (map)"),
        :path_selector        => fun_ref(
          method(:check_path_selector),
          "map (map)"
        ),
        :path_grouping_policy => fun_ref(method(:check_path_gp), "map (map)"),
        :getuid_callout       => fun_ref(
          method(:check_getuid_callout),
          "map (map)"
        ),
        :prio_callout         => fun_ref(
          method(:check_prio_callout),
          "map (map)"
        ),
        :features             => fun_ref(method(:check_features), "map (map)"),
        :path_checker         => fun_ref(
          method(:check_path_checker),
          "map (map)"
        ),
        :failback             => fun_ref(method(:check_failback), "map (map)"),
        :rr_min_io            => fun_ref(method(:check_rr_min_io), "map (map)"),
        :rr_weight            => fun_ref(method(:check_rr_weight), "map (map)"),
        :no_path_retry        => fun_ref(
          method(:check_no_path_retry),
          "map (map)"
        ),
        :user_friendly_names  => fun_ref(
          method(:check_user_friendly_names),
          "map (map)"
        ),
        :wwid                 => fun_ref(method(:check_wwid), "map (map)"),
        :devnode              => fun_ref(method(:check_devnode), "map (map)"),
        :alias                => fun_ref(method(:check_alias), "map (map)"),
        :vendor               => fun_ref(method(:check_vendor), "map (map)"),
        :product              => fun_ref(method(:check_product), "map (map)"),
        :product_blacklist    => fun_ref(
          method(:check_product_blacklist),
          "map (map)"
        ),
        :hardware_handler     => fun_ref(
          method(:check_hardware_handler),
          "map (map)"
        )
      }


      @multipath_detail_items = [
        :path_grouping_policy,
        :path_checker,
        :path_selector,
        :failback,
        :no_path_retry,
        :rr_min_io
      ]

      @multipath_brief_items = [:wwid, :alias]


      @defaults_section_items = [
        :polling_interval,
        :udev_dir,
        :selector,
        :path_grouping_policy,
        :getuid_callout,
        :prio_callout,
        :features,
        :path_checker,
        :path_selector,
        :failback,
        :rr_min_io,
        :rr_weight,
        :no_path_retry,
        :user_friendly_names
      ]

      @device_detail_items = [
        :hardware_handler,
        :path_grouping_policy,
        :getuid_callout,
        :path_selector,
        :path_checker,
        :features,
        :prio_callout,
        :failback,
        :rr_weight,
        :no_path_retry,
        :rr_min_io
      ]

      @device_brief_items = [:vendor, :product, :product_blacklist]

      @blacklist_section_items = [:wwid, :devnode, :vendor, :product]
    end

    #     get a new id for new item, this will help to make each item unique.
    def get_newid(items)
      items = deep_copy(items)
      newid = 0
      Builtins.foreach(items) do |e|
        e_id = 0
        e_id = Builtins.tointeger(Ops.get_string(e, "id", "0"))
        newid = e_id if Ops.less_than(newid, e_id)
      end
      newid = Ops.add(newid, 1)
      Builtins.tostring(newid)
    end

    #    remove all the quotes at head and end.
    #    ignore quotes in the be middle of value
    def rm_quotes(value)
      str_len = 0
      str_start = 0
      str_end = 0

      str_len = Builtins.size(value)
      return "" if Ops.less_or_equal(str_len, 0)
      str_end = Ops.subtract(str_len, 1)
      while Ops.less_than(str_start, str_len)
        cur_char = Builtins.substring(value, str_start, 1)
        if cur_char == " " || cur_char == "\t" || cur_char == "\r" ||
            cur_char == "\n" ||
            cur_char == "\""
          str_start = Ops.add(str_start, 1)
          next
        end
        break
      end

      while Ops.greater_than(str_end, str_start)
        cur_char = Builtins.substring(value, str_end, 1)
        if cur_char == " " || cur_char == "\t" || cur_char == "\r" ||
            cur_char == "\n" ||
            cur_char == "\""
          str_end = Ops.subtract(str_end, 1)
          next
        end
        break
      end
      result = ""
      if Ops.greater_or_equal(str_end, str_start)
        result = Builtins.substring(
          value,
          str_start,
          Ops.add(Ops.subtract(str_end, str_start), 1)
        )
      end
      result
    end

    #     add quotes to configuration value, no matter how many words.
    #     if the value has quotes pair, do not touch it.
    #     if more than 1 quote at the head or end, only keep one.
    #     if there are quote inside the value, ignore.
    def add_quotes(value)
      result = rm_quotes(value)
      if Ops.greater_than(Builtins.size(result), 0)
        result = Ops.add(Ops.add("\"", result), "\"")
      end
      result
    end



    def build_valid_chars(key)
      valid_chars = {
        "path"              => " %./-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
        "wwid"              => ".-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
        "number"            => "0123456789",
        "devnode"           => " ^!\".*?()|[]/\\-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
        "vendor"            => " ^!\".*?()|[]/\\-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
        "product"           => " ^!\".*?()|[]/\\-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
        "product_blacklist" => " ^!\".*?()|[]/\\-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
        "hardware_handler"  => " ^!\".*?()|[]/\\-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
        "alias"             => ".-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      }
      if Builtins.haskey(valid_chars, key) == false
        Popup.Message(Builtins.sformat("can not find valid chars for %1", key))
        return ""
      else
        return Ops.get_string(valid_chars, key, "")
      end
    end

    def build_combobox_list(opts)
      opts = deep_copy(opts)
      combobox_list = []
      Builtins.foreach(Ops.get_list(opts, "list", [])) do |e|
        opt_str = Ops.get_string(e, "optstr", "NA")
        id = Ops.get_symbol(e, "id", :id)
        item = Item(Id(id), opt_str)
        combobox_list = Builtins.add(combobox_list, item)
      end
      if combobox_list == []
        Popup.Message("build_combobox_list: nexpected empty combobox list.")
      end
      deep_copy(combobox_list)
    end

    def build_polling_interval_term(opt)
      entry = Ops.get_map(@polling_interval_opts, "entry", {})
      ret = Empty()
      if entry != {}
        id = Ops.get_symbol(entry, "id", :id)
        label_str = Ops.get_string(entry, "name", "NA")
        ret = TextEntry(Id(id), Opt(:notify), label_str, "")
      else
        Popup.Message("polling_interval_opts[\"entry\"] is not defined")
      end
      deep_copy(ret)
    end

    def update_polling_interval_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "polling_interval", "")
      UI.ChangeWidget(
        Id(:polling_interval),
        :ValidChars,
        build_valid_chars("number")
      )
      UI.ChangeWidget(Id(:polling_interval), :Value, value)

      nil
    end

    def polling_interval_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:polling_interval), :Value)
      if Ops.is_string?(ret) == true
        value = Convert.to_string(ret)
      else
        Popup.Message(
          Builtins.sformat("polling_interval_handler: unexpectd ret %1", ret)
        )
      end
      Ops.set(item, "polling_interval", value)
      deep_copy(item)
    end

    def check_polling_interval(item)
      item = deep_copy(item)
      ret = {}
      value = Ops.get_string(item, "polling_interval", "")
      if value == ""
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      elsif value != "0" && Builtins.substring(value, 0, 1) == "0"
        Ops.set(ret, "result", false)
        Ops.set(
          ret,
          "info",
          "* \"polling_interval\" " + _("should be a decimal integer") + "\n"
        )
      elsif Builtins.tointeger(value) == nil ||
          value != Builtins.tostring(Builtins.tointeger(value))
        Ops.set(ret, "result", false)
        Ops.set(
          ret,
          "info",
          "* \"polling_interval\" " + _("illegal value") + "\n"
        )
      elsif Ops.less_than(Builtins.tointeger(value), 0)
        Ops.set(ret, "result", false)
        Ops.set(
          ret,
          "info",
          "* \"polling_interval\" " + _("should be greater than 0") + "\n"
        )
      elsif value == Builtins.tostring(Builtins.tointeger(value))
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(
          ret,
          "info",
          "* \"polling_interval\" " + _("illegal value") + "\n"
        )
      end
      deep_copy(ret)
    end

    def build_udev_dir_term(opt)
      entry = Ops.get_map(@udev_dir_opts, "entry", {})
      ret = Empty()
      if entry != {}
        id = Ops.get_symbol(entry, "id", :id)
        label_str = Ops.get_string(entry, "name", "NA")
        ret = TextEntry(Id(id), Opt(:notify), label_str, "")
      else
        Popup.Message("udev_dir_opts[\"entry\"] is not defined")
      end
      deep_copy(ret)
    end

    def update_udev_dir_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "udev_dir", "")
      UI.ChangeWidget(Id(:udev_dir), :ValidChars, build_valid_chars("path"))
      UI.ChangeWidget(Id(:udev_dir), :Value, value)

      nil
    end

    def udev_dir_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:udev_dir), :Value)
      if Ops.is_string?(ret)
        value = Convert.to_string(ret)
      else
        Popup.Message(
          Builtins.sformat("udev_dir_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "udev_dir", value)
      deep_copy(item)
    end

    def check_udev_dir(item)
      item = deep_copy(item)
      header = "* \"udev_dir\" "
      ret = {}
      value = Ops.get_string(item, "udev_dir", "")

      if value == "" || value == Builtins.toascii(value)
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", Ops.add(Ops.add(header, _("illegal value")), "\n"))
      end
      deep_copy(ret)
    end

    def build_selector_term(opt)
      ret = Empty()
      if opt == :combobox_only
        ret = ComboBox(
          Id(:selector),
          Opt(:notify),
          Ops.get_string(@optlabel, "selector", "NA"),
          build_combobox_list(@selector_opts)
        )
      elsif opt == :all
        ret = ReplacePoint(
          Id(:replace_selector),
          ComboBox(
            Id(:selector),
            Opt(:notify),
            Ops.get_string(@optlabel, "selector", "NA"),
            build_combobox_list(@selector_opts)
          )
        )
      else
        Popup.Message(
          Builtins.sformat("build_selector_term: unexpected opt %1", opt)
        )
      end
      deep_copy(ret)
    end

    def update_selector_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "selector", "")
      if value == "round-robin 0"
        UI.ChangeWidget(Id(:selector), :Value, :round_robin)
      elsif value == "service-time 0"
        UI.ChangeWidget(Id(:selector), :Value, :service_time)
      elsif value == "queue-length 0"
        UI.ChangeWidget(Id(:selector), :Value, :queue_length)
      elsif value == ""
        UI.ChangeWidget(Id(:selector), :Value, :none)
      else
        Popup.Message(
          Builtins.sformat("update_selector_term: unexpected value %1", value)
        )
      end

      nil
    end

    def selector_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:selector), :Value)
      if ret == :round_robin
        value = "round-robin 0"
      elsif ret == :service_time
        value = "service-time 0"
      elsif ret == :queue_length
        value = "queue-length 0"
      elsif ret == :none
        value = ""
      else
        Popup.Message(
          Builtins.sformat("selector_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "selector", value)
      deep_copy(item)
    end

    def check_selector(item)
      item = deep_copy(item)
      header = "* \"selector\" "
      ret = {}
      value = Ops.get_string(item, "selector", "")
      if value == "" || value == "round-robin 0" || value == "service-time 0" || value =="queue-length 0"
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", Ops.add(Ops.add(header, _("illegal value")), "\n"))
      end
      deep_copy(ret)
    end

    def build_path_selector_term(opt)
      ret = Empty()
      if opt == :combobox_only
        ret = ComboBox(
          Id(:path_selector),
          Opt(:notify),
          Ops.get_string(@optlabel, "path_selector", "NA"),
          build_combobox_list(@path_selector_opts)
        )
      elsif opt == :all
        ret = ReplacePoint(
          Id(:replace_path_selector),
          ComboBox(
            Id(:path_selector),
            Opt(:notify),
            Ops.get_string(@optlabel, "path_selector", "NA"),
            build_combobox_list(@path_selector_opts)
          )
        )
      else
        Popup.Message(
          Builtins.sformat("build_path_selector_term: unexpected opt %1", ret)
        )
      end
      deep_copy(ret)
    end

    def update_path_selector_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "path_selector", "")
      if value == "round-robin 0"
        UI.ChangeWidget(Id(:path_selector), :Value, :round_robin)
      elsif value == "service-time 0"
        UI.ChangeWidget(Id(:path_selector), :Value, :service_time)
      elsif value == "queue-length 0"
        UI.ChangeWidget(Id(:path_selector), :Value, :queue_length)        
      elsif value == ""
        UI.ChangeWidget(Id(:path_selector), :Value, :none)
      else
        Popup.Message(
          Builtins.sformat(
            "update_path_selector_term: unexpected value %1",
            value
          )
        )
      end

      nil
    end

    def path_selector_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:path_selector), :Value)
      if ret == :round_robin
        value = "round-robin 0"
      elsif ret == :service_time
        value = "service-time 0"
      elsif ret == :queue_length
        value = "queue-length 0"        
      elsif ret == :none
        value = ""
      else
        Popup.Message(
          Builtins.sformat("path_selector_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "path_selector", value)
      deep_copy(item)
    end

    def check_path_selector(item)
      item = deep_copy(item)
      ret = {}
      value = Ops.get_string(item, "path_selector", "")
      if value == "" || value == "round-robin 0" || value == "service-time 0" || value == "queue-length 0"
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", "* \"path_selector\" " + _("illegal value") + "\n")
      end
      deep_copy(ret)
    end

    def build_path_gp_term(opt)
      ComboBox(
        Id(:path_grouping_policy),
        Opt(:notify),
        Ops.get_string(@optlabel, "path_grouping_policy", "NA"),
        build_combobox_list(@path_gp_opts)
      )
    end

    def update_path_gp_term(item)
      item = deep_copy(item)
      value = ""
      id = ""

      value = Ops.get_string(item, "path_grouping_policy", "")
      if value == "failover"
        UI.ChangeWidget(Id(:path_grouping_policy), :Value, :failover)
      elsif value == "multibus"
        UI.ChangeWidget(Id(:path_grouping_policy), :Value, :multibus)
      elsif value == "group_by_serial"
        UI.ChangeWidget(Id(:path_grouping_policy), :Value, :group_by_serial)
      elsif value == "group_by_prio"
        UI.ChangeWidget(Id(:path_grouping_policy), :Value, :group_by_prio)
      elsif value == "group_by_node_name"
        UI.ChangeWidget(Id(:path_grouping_policy), :Value, :group_by_node_name)
      else
        UI.ChangeWidget(Id(:path_grouping_policy), :Value, :none)
      end

      nil
    end

    def path_gp_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:path_grouping_policy), :Value)
      if ret == :none
        value = ""
      elsif ret == :failover
        value = "failover"
      elsif ret == :multibus
        value = "multibus"
      elsif ret == :group_by_serial
        value = "group_by_serial"
      elsif ret == :group_by_prio
        value = "group_by_prio"
      elsif ret == :group_by_node_name
        value = "group_by_node_name"
      else
        Popup.Message(
          Builtins.sformat("path_gp_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "path_grouping_policy", value)
      deep_copy(item)
    end

    def check_path_gp(item)
      item = deep_copy(item)
      ret = {}
      value = Ops.get_string(item, "path_grouping_policy", "")
      if value == "" || value == "failover" || value == "multibus" ||
          value == "group_by_serial" ||
          value == "group_by_prio" ||
          value == "group_by_node_name"
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(
          ret,
          "info",
          "* \"path_grouping_policy\" " + _("illegal value") + "\n"
        )
      end
      deep_copy(ret)
    end

    def build_getuid_callout_term(opt)
      ret = Empty()
      if opt == :combobox_only
        ret = ComboBox(
          Id(:getuid_callout),
          Opt(:notify),
          Ops.get_string(@optlabel, "getuid_callout", "NA"),
          build_combobox_list(@getuid_callout_opts)
        )
      elsif opt == :editable_combobox_only
        ret = ComboBox(
          Id(:getuid_callout),
          Opt(:notify, :editable),
          Ops.get_string(@optlabel, "getuid_callout", "NA"),
          build_combobox_list(@getuid_callout_opts)
        )
      elsif opt == :all
        ret = ReplacePoint(
          Id(:replace_getuid_callout),
          ComboBox(
            Id(:getuid_callout),
            Opt(:notify),
            Ops.get_string(@optlabel, "getuid_callout", "NA"),
            build_combobox_list(@getuid_callout_opts)
          )
        )
      else
        Popup.Message(
          Builtins.sformat("build_getuid_callout_term: unexpected opt %1", opt)
        )
      end
      deep_copy(ret)
    end

    def update_getuid_callout_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "getuid_callout", "")
      if value == "/sbin/scsi_id -g -u -s"
        UI.ChangeWidget(Id(:getuid_callout), :Value, :default)
      else
        UI.ReplaceWidget(
          Id(:replace_getuid_callout),
          build_getuid_callout_term(:editable_combobox_only)
        )
        UI.ChangeWidget(
          Id(:getuid_callout),
          :ValidChars,
          build_valid_chars("path")
        )
        UI.ChangeWidget(Id(:getuid_callout), :Value, value)
        UI.SetFocus(Id(:getuid_callout))
      end

      nil
    end

    def getuid_callout_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:getuid_callout), :Value)
      if ret == :default
        UI.ReplaceWidget(
          Id(:replace_getuid_callout),
          build_getuid_callout_term(:combobox_only)
        )
        UI.ChangeWidget(Id(:getuid_callout), :Value, :default)
        value = "/sbin/scsi_id -g -u -s"
      elsif ret == :customized_str
        value = Ops.get_string(@temp_string_values, "getuid_callout", "")
        UI.ReplaceWidget(
          Id(:replace_getuid_callout),
          build_getuid_callout_term(:editable_combobox_only)
        )
        UI.ChangeWidget(
          Id(:getuid_callout),
          :ValidChars,
          build_valid_chars("path")
        )
        UI.ChangeWidget(Id(:getuid_callout), :Value, value)
        UI.SetFocus(Id(:getuid_callout)) 
        #	replacewidget_notify = true;
      elsif ret == ""
        value = ""
      elsif Convert.to_string(ret) == Builtins.toascii(Convert.to_string(ret))
        value = Convert.to_string(ret)
        Ops.set(@temp_string_values, "getuid_callout", value)
      else
        Popup.Message(
          Builtins.sformat("getuid_callout_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "getuid_callout", value)
      deep_copy(item)
    end

    def check_getuid_callout(item)
      item = deep_copy(item)
      header = "* \"getuid_callout\" "
      ret = {}
      value = Ops.get_string(item, "getuid_callout", "")

      if value == "" || value == "/sbin/scsi_id -g -u -s"
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      elsif value == Builtins.toascii(value)
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", Ops.add(Ops.add(header, _("illegal value")), "\n"))
      end
      deep_copy(ret)
    end

    def build_prio_callout_term(opt)
      ret = Empty()
      if opt == :combobox_only
        ret = ComboBox(
          Id(:prio_callout),
          Opt(:notify),
          Ops.get_string(@optlabel, "prio_callout", "NA"),
          build_combobox_list(@prio_callout_opts)
        )
      elsif opt == :all
        ret = ReplacePoint(
          Id(:replace_prio_callout),
          ComboBox(
            Id(:prio_callout),
            Opt(:notify),
            Ops.get_string(@optlabel, "prio_callout", "NA"),
            build_combobox_list(@prio_callout_opts)
          )
        )
      else
        Popup.Message(
          Builtins.sformat("build_prio_callout_term: unexpected opt %1", opt)
        )
      end
      deep_copy(ret)
    end

    def update_prio_callout_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "prio_callout", "")
      if value == "mpath_prio_emc /dev/%n"
        UI.ChangeWidget(Id(:prio_callout), :Value, :prio_emc)
      elsif value == "mpath_prio_alua /dev/%n"
        UI.ChangeWidget(Id(:prio_callout), :Value, :prio_alua)
      elsif value == "mpath_prio_netapp /dev/%n"
        UI.ChangeWidget(Id(:prio_callout), :Value, :prio_netapp)
      elsif value == "mpath_prio_tpc /dev/%n"
        UI.ChangeWidget(Id(:prio_callout), :Value, :prio_tpc)
      elsif value == "mpath_prio_hp_sw /dev/%n"
        UI.ChangeWidget(Id(:prio_callout), :Value, :prio_hp_sw)
      elsif value == "mpath_prio_hds_modular %b"
        UI.ChangeWidget(Id(:prio_callout), :Value, :prio_hds_mod)
      elsif value == ""
        UI.ChangeWidget(Id(:prio_callout), :Value, :none)
      else
        Popup.Message(
          Builtins.sformat(
            "update_prio_callout_term: unexpected value %1",
            value
          )
        )
      end

      nil
    end

    def prio_callout_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:prio_callout), :Value)
      if ret == :prio_emc
        value = "mpath_prio_emc /dev/%n"
      elsif ret == :prio_alua
        value = "mpath_prio_alua /dev/%n"
      elsif ret == :prio_netapp
        value = "mpath_prio_netapp /dev/%n"
      elsif ret == :prio_tpc
        value = "mpath_prio_tpc /dev/%n"
      elsif ret == :prio_hp_sw
        value = "mpath_prio_hp_sw /dev/%n"
      elsif ret == :prio_hds_mod
        value = "mpath_prio_hds_modular %b"
      elsif ret == :none
        value = ""
      else
        Popup.Message(
          Builtins.sformat("prio_callout_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "prio_callout", value)
      deep_copy(item)
    end

    def check_prio_callout(item)
      item = deep_copy(item)
      header = "* \"prio_callout\" "
      ret = {}
      value = Ops.get_string(item, "prio_callout", "")

      if value == "" || value == "mpath_prio_emc /dev/%n" ||
          value == "mpath_prio_alua /dev/%n" ||
          value == "mpath_prio_netapp /dev/%n" ||
          value == "mpath_prio_tpc /dev/%n" ||
          value == "mpath_prio_hp_sw /dev/%n" ||
          value == "mpath_prio_hds_modular %b"
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", Ops.add(Ops.add(header, _("illegal value")), "\n"))
      end
      deep_copy(ret)
    end

    def build_features_term(opt)
      ComboBox(
        Id(:features),
        Opt(:notify),
        Ops.get_string(@optlabel, "features", "NA"),
        build_combobox_list(@features_opts)
      )
    end

    def update_features_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "features", "")

      if value == "1 queue_if_no_path"
        UI.ChangeWidget(Id(:features), :Value, :queue_if_no_path)
      elsif value == "0"
        UI.ChangeWidget(Id(:features), :Value, :zero)
      elsif value == ""
        UI.ChangeWidget(Id(:features), :Value, :none)
      else
        Popup.Message(
          Builtins.sformat("update_features_term: unexpected value %1", value)
        )
      end

      nil
    end

    def features_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:features), :Value)
      if ret == :queue_if_no_path
        value = "1 queue_if_no_path"
      elsif ret == :zero
        value = "0"
      elsif ret == :none
        value = ""
      else
        Popup.Message(
          Builtins.sformat("features_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "features", value)
      deep_copy(item)
    end

    def check_features(item)
      item = deep_copy(item)
      header = "* \"features\" "
      ret = {}
      value = Ops.get_string(item, "features", "")
      if value == "" || value == "1 queue_if_no_path" || value == "0"
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", Ops.add(Ops.add(header, _("illegal value")), "\n"))
      end
      deep_copy(ret)
    end

    def build_path_checker_term(opt)
      ret = Empty()
      if opt == :combobox_only
        ret = ComboBox(
          Id(:path_checker),
          Opt(:notify),
          Ops.get_string(@optlabel, "path_checker", "NA"),
          build_combobox_list(@path_checker_opts)
        )
      elsif opt == :all
        ret = ReplacePoint(
          Id(:replace_path_checker),
          ComboBox(
            Id(:path_checker),
            Opt(:notify),
            Ops.get_string(@optlabel, "path_checker", "NA"),
            build_combobox_list(@path_checker_opts)
          )
        )
      else
        Popup.Message(
          Builtins.sformat("build_path_checker_term: unexpected opt %1", opt)
        )
      end
      deep_copy(ret)
    end

    def update_path_checker_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "path_checker", "")
      if value == "readsector0"
        UI.ChangeWidget(Id(:path_checker), :Value, :readsector0)
      elsif value == "tur"
        UI.ChangeWidget(Id(:path_checker), :Value, :tur)
      elsif value == "emc_clariion"
        UI.ChangeWidget(Id(:path_checker), :Value, :emc_clariion)
      elsif value == "hp_sw"
        UI.ChangeWidget(Id(:path_checker), :Value, :hp_sw)
      elsif value == "rdac"
        UI.ChangeWidget(Id(:path_checker), :Value, :rdac)
      elsif value == "directio"
        UI.ChangeWidget(Id(:path_checker), :Value, :directio)
      elsif value == ""
        UI.ChangeWidget(Id(:path_checker), :Value, :none)
      else
        Popup.Message(
          Builtins.sformat(
            "update_path_checker_term: unexpected value %1",
            value
          )
        )
      end

      nil
    end

    def path_checker_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:path_checker), :Value)
      if ret == :none
        value = ""
      elsif ret == :readsector0
        value = "readsector0"
      elsif ret == :tur
        value = "tur"
      elsif ret == :emc_clariion
        value = "emc_clariion"
      elsif ret == :hp_sw
        value = "hp_sw"
      elsif ret == :rdac
        value = "rdac"
      elsif ret == :directio
        value = "directio"
      else
        Popup.Message(
          Builtins.sformat("path_checker_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "path_checker", value)
      deep_copy(item)
    end

    def check_path_checker(item)
      item = deep_copy(item)
      ret = {}
      value = Ops.get_string(item, "path_checker", "")
      if value == "" || value == "readsector0" || value == "tur" ||
          value == "emc_clariion" ||
          value == "hp_sw" ||
          value == "rdac" ||
          value == "directio"
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", "* \"path_checker\" " + _("illegal value") + "\n")
      end
      deep_copy(ret)
    end

    def build_failback_term(opt)
      ret = Empty()
      if opt == :editable_combobox_only
        ret = ComboBox(
          Id(:failback),
          Opt(:notify, :editable),
          Ops.get_string(@optlabel, "failback", "NA"),
          build_combobox_list(@failback_opts)
        )
      elsif opt == :combobox_only
        ret = ComboBox(
          Id(:failback),
          Opt(:notify),
          Ops.get_string(@optlabel, "failback", "NA"),
          build_combobox_list(@failback_opts)
        )
      elsif opt == :all
        ret = ReplacePoint(
          Id(:replace_failback),
          ComboBox(
            Id(:failback),
            Opt(:notify),
            Ops.get_string(@optlabel, "failback", "NA"),
            build_combobox_list(@failback_opts)
          )
        )
      else
        Popup.Message(
          Builtins.sformat("build_failback_term: unexpected opt %1", opt)
        )
      end

      deep_copy(ret)
    end

    def update_failback_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "failback", "")
      if value == "manual"
        UI.ChangeWidget(Id(:failback), :Value, :manual)
      elsif value == "immediate"
        UI.ChangeWidget(Id(:failback), :Value, :immediate)
      else
        UI.ReplaceWidget(
          Id(:replace_failback),
          build_failback_term(:editable_combobox_only)
        )
        UI.ChangeWidget(Id(:failback), :ValidChars, build_valid_chars("number"))
        UI.ChangeWidget(Id(:failback), :Value, value)
        Ops.set(@temp_string_values, "failback", value)
      end

      nil
    end

    def failback_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:failback), :Value)
      if ret == :immediate
        UI.ReplaceWidget(
          Id(:replace_failback),
          build_failback_term(:combobox_only)
        )
        UI.ChangeWidget(Id(:failback), :Value, :immediate)
        value = "immediate"
      elsif ret == :manual
        UI.ReplaceWidget(
          Id(:replace_failback),
          build_failback_term(:combobox_only)
        )
        UI.ChangeWidget(Id(:failback), :Value, :manual)
        value = "manual"
      elsif ret == :customized_str
        value = Ops.get_string(@temp_string_values, "failback", "")
        UI.ReplaceWidget(
          Id(:replace_failback),
          build_failback_term(:editable_combobox_only)
        )
        UI.ChangeWidget(Id(:failback), :ValidChars, build_valid_chars("number"))
        UI.ChangeWidget(Id(:failback), :Value, value)
        UI.SetFocus(Id(:failback))
        @replacewidget_notify = true
      elsif ret == "0"
        value = ""
        UI.ReplaceWidget(
          Id(:replace_failback),
          build_failback_term(:editable_combobox_only)
        )
        UI.ChangeWidget(Id(:failback), :ValidChars, build_valid_chars("number"))
        UI.SetFocus(Id(:failback))
        UI.ChangeWidget(Id(:failback), :Value, " ")
        @replacewidget_notify = true
      elsif ret == ""
        value = ""
      elsif Builtins.tointeger(ret) != nil
        value = Convert.to_string(ret)
        Ops.set(@temp_string_values, "failback", value)
      else
        Popup.Message(
          Builtins.sformat("failback_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "failback", value)
      deep_copy(item)
    end

    def check_failback(item)
      item = deep_copy(item)
      ret = {}
      value = Ops.get_string(item, "failback", "")
      if value == "" || value == "immediate" || value == "manual"
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      elsif Builtins.substring(value, 0, 1) == "0"
        Ops.set(ret, "result", false)
        Ops.set(
          ret,
          "info",
          "* \"failback\" " + _("should be a decimal integer") + "\n"
        )
      elsif Builtins.tointeger(value) == nil ||
          value != Builtins.tostring(Builtins.tointeger(value)) ||
          value == "0"
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", "* \"failback\" " + _("illegal value") + "\n")
      elsif Ops.less_or_equal(Builtins.tointeger(value), 0)
        Ops.set(ret, "result", false)
        Ops.set(
          ret,
          "info",
          "* \"failback\" " + _("should be greater than 0") + "\n"
        )
      elsif value == Builtins.tostring(Builtins.tointeger(value))
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", "* \"failback\" " + _("illegal value") + "\n")
      end
      deep_copy(ret)
    end

    def build_rr_min_io_term(opt)
      entry = Ops.get_map(@rr_min_io_opts, "entry", {})
      ret = Empty()
      if entry != {}
        id = Ops.get_symbol(entry, "id", :id)
        label_str = Ops.get_string(entry, "name", "NA")
        ret = TextEntry(Id(id), Opt(:notify), label_str, "")
      else
        Popup.Message("rr_min_io_opts[\"entry\"] is not defined")
      end
      deep_copy(ret)
    end

    def update_rr_min_io_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "rr_min_io", "")
      UI.ChangeWidget(Id(:rr_min_io), :ValidChars, build_valid_chars("number"))
      UI.ChangeWidget(Id(:rr_min_io), :Value, value)

      nil
    end

    def rr_min_io_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:rr_min_io), :Value)
      value = Convert.to_string(ret) if Builtins.tointeger(ret) != nil
      Ops.set(item, "rr_min_io", value)
      deep_copy(item)
    end

    def check_rr_min_io(item)
      item = deep_copy(item)
      ret = {}
      value = Ops.get_string(item, "rr_min_io", "")
      if value != "0" && Builtins.substring(value, 0, 1) == "0"
        Ops.set(ret, "result", false)
        Ops.set(
          ret,
          "info",
          "* \"rr_min_io\" " + _("should be a decimal integer") + "\n"
        )
      elsif value == ""
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      elsif Builtins.tointeger(value) == nil ||
          value != Builtins.tostring(Builtins.tointeger(value))
        Ops.set(ret, "result", false)
        Ops.set(
          ret,
          "info",
          "* \"rr_min_io\" " + _("invalid decimal integer") + "\n"
        )
      elsif value == Builtins.tostring(Builtins.tointeger(value))
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", "* \"rr_min_io\" " + _("illegal value") + "\n")
      end
      deep_copy(ret)
    end

    def build_rr_weight_term(opt)
      ComboBox(
        Id(:rr_weight),
        Opt(:notify),
        Ops.get_string(@optlabel, "rr_weight", "NA"),
        build_combobox_list(@rr_weight_opts)
      )
    end

    def update_rr_weight_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "rr_weight", "")
      if value == "priorities"
        UI.ChangeWidget(Id(:rr_weight), :Value, :priorities)
      elsif value == "uniform"
        UI.ChangeWidget(Id(:rr_weight), :Value, :uniform)
      elsif value == ""
        UI.ChangeWidget(Id(:rr_weight), :Value, :none)
      else
        Popup.Message(
          Builtins.sformat("update_rr_weight_term: unexpected value %1", value)
        )
      end

      nil
    end

    def rr_weight_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:rr_weight), :Value)
      if ret == :priorities
        value = "priorities"
      elsif ret == :uniform
        value = "uniform"
      elsif ret == :none
        value = ""
      else
        Popup.Message(
          Builtins.sformat("rr_weight_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "rr_weight", value)
      deep_copy(item)
    end

    def check_rr_weight(item)
      item = deep_copy(item)
      header = "* \"rr_weight\" "
      ret = {}
      value = Ops.get_string(item, "rr_weight", "")
      if value == "" || value == "priorities" || value == "uniform"
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", Ops.add(Ops.add(header, _("illegal value")), "\n"))
      end
      deep_copy(ret)
    end

    def build_no_path_retry_term(opt)
      ret = Empty()
      if opt == :combobox_only
        ret = ComboBox(
          Id(:no_path_retry),
          Opt(:notify),
          Ops.get_string(@optlabel, "no_path_retry", "NA"),
          build_combobox_list(@no_path_retry_opts)
        )
      elsif opt == :editable_combobox_only
        ret = ComboBox(
          Id(:no_path_retry),
          Opt(:notify, :editable),
          Ops.get_string(@optlabel, "no_path_retry", "NA"),
          build_combobox_list(@no_path_retry_opts)
        )
      elsif opt == :all
        ret = ReplacePoint(
          Id(:replace_no_path_retry),
          ComboBox(
            Id(:no_path_retry),
            Opt(:notify),
            Ops.get_string(@optlabel, "no_path_retry", "NA"),
            build_combobox_list(@no_path_retry_opts)
          )
        )
      else
        Popup.Message(
          Builtins.sformat("build_no_path_retry_term: unexpected opt %1", opt)
        )
      end
      deep_copy(ret)
    end

    def update_no_path_retry_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "no_path_retry", "")
      if value == "fail"
        UI.ChangeWidget(Id(:no_path_retry), :Value, :fail)
      elsif value == "queue"
        UI.ChangeWidget(Id(:no_path_retry), :Value, :queue)
      else
        UI.ReplaceWidget(
          Id(:replace_no_path_retry),
          build_no_path_retry_term(:editable_combobox_only)
        )
        UI.ChangeWidget(
          Id(:no_path_retry),
          :ValidChars,
          build_valid_chars("number")
        )
        UI.ChangeWidget(Id(:no_path_retry), :Value, value)
        Ops.set(@temp_string_values, "no_path_retry", value)
      end

      nil
    end

    def no_path_retry_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:no_path_retry), :Value)
      if ret == :fail
        UI.ReplaceWidget(
          Id(:replace_no_path_retry),
          build_no_path_retry_term(:combobox_only)
        )
        UI.ChangeWidget(Id(:no_path_retry), :Value, :fail)
        value = "fail"
      elsif ret == :queue
        UI.ReplaceWidget(
          Id(:replace_no_path_retry),
          build_no_path_retry_term(:combobox_only)
        )
        UI.ChangeWidget(Id(:no_path_retry), :Value, :queue)
        value = "queue"
      elsif ret == :customized_str
        value = Ops.get_string(@temp_string_values, "no_path_retry", "")
        UI.ReplaceWidget(
          Id(:replace_no_path_retry),
          build_no_path_retry_term(:editable_combobox_only)
        )
        UI.ChangeWidget(
          Id(:no_path_retry),
          :ValidChars,
          build_valid_chars("number")
        )
        UI.ChangeWidget(Id(:no_path_retry), :Value, value)
        UI.SetFocus(Id(:no_path_retry))
        @replacewidget_notify = true
      elsif ret == ""
        UI.ReplaceWidget(
          Id(:replace_no_path_retry),
          build_no_path_retry_term(:editable_combobox_only)
        )
        UI.ChangeWidget(
          Id(:no_path_retry),
          :ValidChars,
          build_valid_chars("number")
        )
        UI.SetFocus(Id(:no_path_retry))
        UI.ChangeWidget(Id(:no_path_retry), :Value, "")
        value = ""
        Ops.set(@temp_string_values, "no_path_retry", value)
        @replacewidget_notify = true
      elsif Builtins.tointeger(ret) != nil
        value = Convert.to_string(ret)
        Ops.set(@temp_string_values, "no_path_retry", value)
      else
        Popup.Message(
          Builtins.sformat("no_path_retry_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "no_path_retry", value)
      deep_copy(item)
    end

    def check_no_path_retry(item)
      item = deep_copy(item)
      ret = {}
      value = Ops.get_string(item, "no_path_retry", "")
      if value == "" || value == "fail" || value == "queue"
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      elsif value != "0" && Builtins.substring(value, 0, 1) == "0"
        Ops.set(ret, "result", false)
        Ops.set(
          ret,
          "info",
          "* \"no_path_retry\" " + _("should be a decimal integer") + "\n"
        )
      elsif Builtins.tointeger(value) == nil ||
          value != Builtins.tostring(Builtins.tointeger(value))
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", "* \"no_path_retry\" " + _("illegal value") + "\n")
      elsif value == Builtins.tostring(Builtins.tointeger(value))
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", "* \"no_path_retry\" " + _("illegal value") + "\n")
      end
      deep_copy(ret)
    end

    def build_user_friendly_names_term(opt)
      ComboBox(
        Id(:user_friendly_names),
        Opt(:notify),
        Ops.get_string(@optlabel, "user_friendly_names", "NA"),
        build_combobox_list(@user_friendly_names_opts)
      )
    end

    def update_user_friendly_names_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "user_friendly_names", "")
      if value == "yes"
        UI.ChangeWidget(Id(:user_friendly_names), :Value, :yes)
      elsif value == "no"
        UI.ChangeWidget(Id(:user_friendly_names), :Value, :no)
      elsif value == ""
        UI.ChangeWidget(Id(:user_friendly_names), :Value, :none)
      else
        Popup.Message(
          Builtins.sformat(
            "update_user_friendly_names_term: unexpected value %1",
            value
          )
        )
      end

      nil
    end

    def user_friendly_names_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:user_friendly_names), :Value)
      if ret == :yes
        value = "yes"
      elsif ret == :no
        value = "no"
      elsif ret == :none
        value = ""
      else
        Popup.Message(
          Builtins.sformat(
            "user_friendly_names_handler: unexpected ret %1",
            ret
          )
        )
      end
      Ops.set(item, "user_friendly_names", value)
      deep_copy(item)
    end

    def check_user_friendly_names(item)
      item = deep_copy(item)
      header = "* \"user_friendly_names\" "
      ret = {}
      value = Ops.get_string(item, "user_friendly_names", "")
      if value == "" || value == "yes" || value == "no"
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", Ops.add(Ops.add(header, _("illegal value")), "\n"))
      end
      deep_copy(ret)
    end

    def build_wwid_term(opt)
      entry = Ops.get_map(@wwid_opts, "entry", {})
      ret = Empty()
      if entry != {}
        id = Ops.get_symbol(entry, "id", :id)
        label_str = Ops.get_string(entry, "name", "NA")
        ret = TextEntry(Id(id), Opt(:notify), label_str, "")
      else
        Popup.Message("wwid_opt[\"entry\"] is not defined")
      end
      deep_copy(ret)
    end

    def update_wwid_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "wwid", "")
      UI.ChangeWidget(Id(:wwid), :ValidChars, build_valid_chars("wwid"))
      UI.ChangeWidget(Id(:wwid), :Value, value)

      nil
    end

    def wwid_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:wwid), :Value)
      if Ops.is_string?(ret) == true
        value = Convert.to_string(ret)
      else
        Popup.Message(Builtins.sformat("wwid_handler: unexpected ret %1", ret))
      end
      Ops.set(item, "wwid", value)
      deep_copy(item)
    end

    def check_wwid(item)
      item = deep_copy(item)
      ret = {}
      value = Ops.get_string(item, "wwid", "")
      if value == "" || Builtins.regexpmatch(value, "^[ \t]+$")
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", "* \"wwid\" " + _("should not be empty") + "\n")
      else
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      end
      deep_copy(ret)
    end

    def build_devnode_term(opt)
      entry = Ops.get_map(@devnode_opts, "entry", {})
      ret = Empty()
      if entry != {}
        id = Ops.get_symbol(entry, "id", :id)
        label_str = Ops.get_string(entry, "name", "NA")
        ret = TextEntry(Id(id), Opt(:notify), label_str, "")
      else
        Popup.Message("devnode_opts[\"entry\"] is not defined")
      end
      deep_copy(ret)
    end

    def update_devnode_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "devnode", "")
      UI.ChangeWidget(Id(:devnode), :ValidChars, build_valid_chars("devnode"))
      UI.ChangeWidget(Id(:devnode), :Value, value)

      nil
    end

    def devnode_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:devnode), :Value)
      if Ops.is_string?(ret) == true
        value = Convert.to_string(ret)
      else
        Popup.Message(
          Builtins.sformat("devnode_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "devnode", value)
      deep_copy(item)
    end

    def check_devnode(item)
      item = deep_copy(item)
      header = "* \"devnode\" "
      ret = {}
      value = Ops.get_string(item, "devnode", "")
      if value == "" || Builtins.regexpmatch(value, "^[ \t]+$")
        Ops.set(ret, "result", false)
        Ops.set(
          ret,
          "info",
          Ops.add(Ops.add(header, _("should not be empty")), "\n")
        )
      else
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      end
      deep_copy(ret)
    end

    def build_alias_term(opt)
      entry = Ops.get_map(@alias_opts, "entry", {})
      ret = Empty()
      if entry != {}
        id = Ops.get_symbol(entry, "id", :id)
        label_str = Ops.get_string(entry, "name", "NA")
        ret = TextEntry(Id(id), Opt(:notify), label_str, "")
      else
        Popup.Message("alias_opts[\"entry\"] is not defined")
      end
      deep_copy(ret)
    end

    def update_alias_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "alias", "")
      UI.ChangeWidget(Id(:alias), :ValidChars, build_valid_chars("alias"))
      UI.ChangeWidget(Id(:alias), :Value, value)

      nil
    end

    def alias_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:alias), :Value)
      if Ops.is_string?(ret) == true
        value = Convert.to_string(ret)
      else
        Popup.Message(Builtins.sformat("alias_handler: unexpected ret %1", ret))
      end
      Ops.set(item, "alias", value)
      deep_copy(item)
    end

    def check_alias(item)
      item = deep_copy(item)
      ret = {}
      value = Ops.get_string(item, "alias", "")
      if value == Builtins.toascii(value)
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", "* \"alias\" " + _("illegal value") + "\n")
      end
      deep_copy(ret)
    end

    def build_vendor_term(opt)
      entry = Ops.get_map(@vendor_opts, "entry", {})
      ret = Empty()
      if entry != {}
        id = Ops.get_symbol(entry, "id", :id)
        label_str = Ops.get_string(entry, "name", "NA")
        ret = TextEntry(Id(id), Opt(:notify), label_str, "")
      else
        Popup.Message("vendor_opts[\"entry\"] is not defined")
      end
      deep_copy(ret)
    end

    def update_vendor_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "vendor", "")
      UI.ChangeWidget(Id(:vendor), :ValidChars, build_valid_chars("vendor"))
      UI.ChangeWidget(Id(:vendor), :Value, value)

      nil
    end

    def vendor_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:vendor), :Value)
      if Ops.is_string?(ret) == true
        value = Convert.to_string(ret)
      else
        Popup.Message(
          Builtins.sformat("vendor_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "vendor", value)
      deep_copy(item)
    end

    def check_vendor(item)
      item = deep_copy(item)
      header = "* \"vendor\" "
      ret = {}
      value = Ops.get_string(item, "vendor", "")
      if value == "" || Builtins.regexpmatch(value, "^[ \t]+$")
        Ops.set(ret, "result", false)
        Ops.set(
          ret,
          "info",
          Ops.add(Ops.add(header, _("should not be empty")), "\n")
        )
      else
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      end
      deep_copy(ret)
    end

    def build_product_term(opt)
      entry = Ops.get_map(@product_opts, "entry", {})
      ret = Empty()
      if entry != {}
        id = Ops.get_symbol(entry, "id", :id)
        label_str = Ops.get_string(entry, "name", "NA")
        ret = TextEntry(Id(id), Opt(:notify), label_str, "")
      else
        Popup.Message("product_opts[\"entry\"] is not defined")
      end
      deep_copy(ret)
    end

    def update_product_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "product", "")
      UI.ChangeWidget(Id(:product), :ValidChars, build_valid_chars("product"))
      UI.ChangeWidget(Id(:product), :Value, value)
      nil
    end

    def product_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:product), :Value)
      if Ops.is_string?(ret) == true
        value = Convert.to_string(ret)
      else
        Popup.Message(
          Builtins.sformat("product_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "product", value)
      deep_copy(item)
    end

    def check_product(item)
      item = deep_copy(item)
      header = "* \"product\" "
      ret = {}
      value = Ops.get_string(item, "product", "")
      if value == "" || Builtins.regexpmatch(value, "^[ \t]+$")
        Ops.set(ret, "result", false)
        Ops.set(
          ret,
          "info",
          Ops.add(Ops.add(header, _("should not be empty")), "\n")
        )
      else
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      end
      deep_copy(ret)
    end

    def build_product_blacklist_term(opt)
      entry = Ops.get_map(@product_blacklist_opts, "entry", {})
      ret = Empty()
      if entry != {}
        id = Ops.get_symbol(entry, "id", :id)
        label_str = Ops.get_string(entry, "name", "NA")
        ret = TextEntry(Id(id), Opt(:notify), label_str, "")
      else
        Popup.Message("product_blacklist_opts[\"entry\"] is not defined")
      end
      deep_copy(ret)
    end

    def update_product_blacklist_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "product_blacklist", "")
      UI.ChangeWidget(
        Id(:product_blacklist),
        :ValidChars,
        build_valid_chars("product_blacklist")
      )
      UI.ChangeWidget(Id(:product_blacklist), :Value, value)

      nil
    end

    def product_blacklist_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:product_blacklist), :Value)
      if Ops.is_string?(ret) == true
        value = Convert.to_string(ret)
      else
        Popup.Message(
          Builtins.sformat("product_blacklist_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "product_blacklist", value)
      deep_copy(item)
    end

    def check_product_blacklist(item)
      item = deep_copy(item)
      header = "* \"product_blacklist\" "
      ret = {}
      value = Ops.get_string(item, "product_blacklist", "")
      if value != Builtins.toascii(value)
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", Ops.add(Ops.add(header, _("illegal value")), "\n"))
      else
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      end
      deep_copy(ret)
    end

    def build_hardware_handler_term(opt)
      entry = Ops.get_map(@hardware_handler_opts, "entry", {})
      ret = Empty()
      if entry != {}
        id = Ops.get_symbol(entry, "id", :id)
        label_str = Ops.get_string(entry, "name", "NA")
        ret = TextEntry(Id(id), Opt(:notify), label_str, "")
      else
        Popup.Message("hardware_opt[\"entry\"] is not defined")
      end
      deep_copy(ret)
    end

    def update_hardware_handler_term(item)
      item = deep_copy(item)
      value = Ops.get_string(item, "hardware_handler", "")
      UI.ChangeWidget(
        Id(:hardware_handler),
        :ValidChars,
        build_valid_chars("hardware_handler")
      )
      UI.ChangeWidget(Id(:hardware_handler), :Value, value)

      nil
    end

    def hardware_handler_handler(item)
      item = deep_copy(item)
      value = ""
      ret = UI.QueryWidget(Id(:hardware_handler), :Value)
      if Ops.is_string?(ret) == true
        value = Convert.to_string(ret)
      else
        Popup.Message(
          Builtins.sformat("hardware_handler_handler: unexpected ret %1", ret)
        )
      end
      Ops.set(item, "hardware_handler", value)
      deep_copy(item)
    end

    def check_hardware_handler(item)
      item = deep_copy(item)
      header = "* \"hardware_handler\" "
      ret = {}
      value = Ops.get_string(item, "hardware_handler", "")


      if value == "" || value == Builtins.toascii(value)
        Ops.set(ret, "result", true)
        Ops.set(ret, "info", "")
      else
        Ops.set(ret, "result", false)
        Ops.set(ret, "info", Ops.add(Ops.add(header, _("illegal value")), "\n"))
      end
      deep_copy(ret)
    end
  end
end
