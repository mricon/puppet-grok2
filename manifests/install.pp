# == Class: grok2::install
#
# Install class for grokmirror
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
class grok2::install {
  if ($grok2::manage_package) {
    ensure_packages ([
      $grok2::package_name,
    ],
    { ensure => $grok2::package_ensure }
    )
  }

  file { $grok2::global_toplevel:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}
