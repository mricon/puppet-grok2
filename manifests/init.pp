# == Class: grok2
#
# Main class for grokmirror
#
# === Authors
#
# Konstantin Ryabitsev <konstantin@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2016-2020 Konstantin Ryabitsev
#
# === License
#
# @License Apache-2.0 <http://spdx.org/licenses/Apache-2.0>
class grok2 (
  Boolean               $manage_package     = $grok2::params::manage_package,
  String                $package_name       = $grok2::params::package_name,
  Enum['present','absent','installed','latest']
                        $package_ensure     = $grok2::params::package_ensure,
  Pattern['^\/']        $global_toplevel    = $grok2::params::global_toplevel,
  String                $owner              = $grok2::params::owner,
  String                $group              = $grok2::params::group,

  Hash $sites = {},

) inherits grok2::params {

  include 'grok2::install'
  create_resources('grok2::resource::site', $sites)

}
