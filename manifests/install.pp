# == Class: grokmirror::install
#
# Install class for grokmirror
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
class grokmirror::install {
  if ($grokmirror::git_manage_package) {
    ensure_packages ([
      $grokmirror::git_package_name,
    ],
    { ensure => $grokmirror::git_package_ensure }
    )
  }

  if ($grokmirror::manage_package) {
    ensure_packages ([
      $grokmirror::package_name,
    ],
    { ensure => $grokmirror::package_ensure }
    )
  }

  file { $grokmirror::global_toplevel:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  $logdir = $grokmirror::global_logdir

  file { $logdir:
    ensure => 'directory',
    owner  => $grokmirror::user,
    group  => $grokmirror::group,
    mode   => '0755',
  }

  file { '/etc/logrotate.d/grokmirror':
    ensure   => present,
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
    content  => template('grokmirror/logrotate.conf.erb'),
    checksum => 'md5',
  }

  file { $grokmirror::global_configdir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  if $grokmirror::manage_group {
    group { $grokmirror::group:
      ensure => present,
    }
  }
  if $grokmirror::manage_user {
    user { $grokmirror::user:
      ensure => present,
      gid    => $grokmirror::group,
      home   => $grokmirror::global_toplevel,
      shell  => '/sbin/nologin',
    }
  }
}
