# == Class: grokmirror
#
# Main class for grokmirror
#
# === Authors
#
# Konstantin Ryabitsev <konstantin@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2016 Konstantin Ryabitsev
#
# === License
#
# @License Apache-2.0 <http://spdx.org/licenses/Apache-2.0>
class grokmirror (
  Boolean               $manage_package     = $grokmirror::params::manage_package,
  String                $package_name       = $grokmirror::params::package_name,
  Enum['present','absent','installed','latest']
                        $package_ensure     = $grokmirror::params::package_ensure,
  Boolean               $git_manage_package = $grokmirror::params::git_manage_package,
  String                $git_package_name   = $grokmirror::params::git_package_name,
  Enum['present','absent','installed','latest']
                        $git_package_ensure = $grokmirror::params::git_package_ensure,

  Pattern['^\/']        $global_configdir   = $grokmirror::params::global_configdir,
  Pattern['^\/']        $global_toplevel    = $grokmirror::params::global_toplevel,
  Pattern['^\/']        $global_logdir      = $grokmirror::params::global_logdir,
  Enum['debug','info']  $global_loglevel    = $grokmirror::params::global_loglevel,
  String                $user               = $grokmirror::params::user,
  Boolean               $manage_user        = $grokmirror::params::manage_user,
  String                $group              = $grokmirror::params::group,
  Boolean               $manage_group       = $grokmirror::params::manage_group,
  Pattern['^\/']        $pull_command       = $grokmirror::params::pull_command,
  Pattern['^\/']        $fsck_command       = $grokmirror::params::fsck_command,
  String                $cron_environment   = $grokmirror::params::cron_environment,

  Hash $sites = {},

) inherits grokmirror::params {

  include 'grokmirror::install'
  create_resources('grokmirror::resource::site', $sites)

}
