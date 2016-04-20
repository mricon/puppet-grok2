class grokmirror::install {
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
      home   => $grokmirror::global_toplevel,
      shell  => '/sbin/nologin',
    }
  }
}
