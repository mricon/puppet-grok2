# == Class: grok2::params
#
# Configuration parameters for grokmirror
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
#

class grok2::params {
  $manage_package  = true
  $package_name    = 'python3-grokmirror'
  $package_ensure  = 'installed'
  $global_toplevel = '/var/lib/git'
  $global_seltype  = 'git_sys_content_t'
  $owner           = 'mirror'
  $group           = 'mirror'
}
