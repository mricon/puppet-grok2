# == Class: grokmirror::params
#
# Configuration parameters for grokmirror
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
#

class grokmirror::params {
  $manage_package      = true
  $package_name        = 'python-grokmirror'
  $package_ensure      = 'installed'

  $git_manage_package  = true
  $git_package_name    = 'git'
  $git_package_ensure  = 'installed'

  $global_configdir    = '/etc/grokmirror'
  $global_toplevel     = '/var/lib/git'
  $global_logdir       = '/var/log/grokmirror'
  $global_loglevel     = 'info'
  $user                = 'grokmirror'
  $manage_user         = true
  $group               = 'grokmirror'
  $manage_group        = true
  $pull_command        = '/usr/bin/grok-pull'
  $fsck_command        = '/usr/bin/grok-fsck'
  $cron_environment    = 'PATH=/bin:/usr/bin'
}
