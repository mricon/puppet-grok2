define grok2::resource::site (

  Enum['present','absent']  $ensure   = 'present',
  Pattern['^\/']            $toplevel = "${grok2::global_toplevel}/${name}",
  Hash                      $config   = undef,

  Optional[String]          $pull_service_overrides = undef,
  Optional[String]          $fsck_service_overrides = undef,
  Optional[String]          $fsck_timer_overrides   = undef,
  Optional[String]          $sysconfig_env_opts     = undef,
  Boolean                   $enable_pull            = true,
  Boolean                   $enable_fsck            = true,
) {

  $sitename = $name

  # We create this if we are asked to be present, but we don't delete it
  # because we don't want to inadvertently delete git repos
  if $ensure == 'present' {
    file { $toplevel:
      ensure  => 'directory',
      owner   => $grok2::owner,
      group   => $grok2::group,
      mode    => '0755',
      require => [
        File[$grok2::global_toplevel],
      ],
    }
  }

  file { "/etc/grokmirror/${sitename}.conf":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('grok2/grokmirror.conf.erb'),
    require => Package[$grok2::package_name],
  }

  if $pull_service_overrides {
    file { "/etc/systemd/system/grok-pull@${sitename}.service.d":
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Package[$grok2::package_name],
    }
    file { "/etc/systemd/system/grok-pull@${sitename}.service.d/10-puppet-overrides.conf":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => [
        File["/etc/systemd/system/grok-pull@${sitename}.service.d"],
      ],
      content => $pull_service_overrides,
      notify  => Service["grok-pull@${sitename}.service"],
    }
  } else {
    file { "/etc/systemd/system/grok-pull@${sitename}.service.d/10-puppet-overrides.conf":
      ensure => absent,
      notify => Service["grok-pull@${sitename}.service"],
    }
  }

  if $fsck_service_overrides {
    file { "/etc/systemd/system/grok-fsck@${sitename}.service.d":
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Package[$grok2::package_name],
    }
    file { "/etc/systemd/system/grok-fsck@${sitename}.service.d/10-puppet-overrides.conf":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => [
        File["/etc/systemd/system/grok-fsck@${sitename}.service.d"],
      ],
      content => $fsck_service_overrides,
    }
  } else {
    file { "/etc/systemd/system/grok-fsck@${sitename}.service.d/10-puppet-overrides.conf":
      ensure => absent,
    }
  }

  if $fsck_timer_overrides {
    file { "/etc/systemd/system/grok-fsck@${sitename}.timer.d":
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Package[$grok2::package_name],
    }
    file { "/etc/systemd/system/grok-fsck@${sitename}.timer.d/10-puppet-overrides.conf":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => [
        File["/etc/systemd/system/grok-fsck@${sitename}.timer.d"],
      ],
      content => $fsck_timer_overrides,
      notify  => Service["grok-fsck@${sitename}.timer"],
    }
  } else {
    file { "/etc/systemd/system/grok-fsck@${sitename}.timer.d/10-puppet-overrides.conf":
      ensure => absent,
      notify => Service["grok-fsck@${sitename}.timer"],
    }
  }

  if $sysconfig_env_opts {
    file { "/etc/sysconfig/grokmirror.${sitename}":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $sysconfig_env_opts,
      notify  => [
        Service["grok-pull@${sitename}.service"],
        Service["grok-fsck@${sitename}.timer"],
      ],
    }
  } else {
    file { "/etc/sysconfig/grokmirror.${sitename}":
      ensure => absent,
      notify => [
        Service["grok-pull@${sitename}.service"],
        Service["grok-fsck@${sitename}.timer"],
      ],
    }
  }

  exec { "refresh_systemd_overrides_${sitename}":
    command     =>  '/bin/systemctl daemon-reload',
    refreshonly =>  true,
    subscribe   =>  [
      File["/etc/systemd/system/grok-pull@${sitename}.service.d/10-puppet-overrides.conf"],
      File["/etc/systemd/system/grok-fsck@${sitename}.service.d/10-puppet-overrides.conf"],
      File["/etc/systemd/system/grok-fsck@${sitename}.timer.d/10-puppet-overrides.conf"],
    ],
    before      =>  [
      Service["grok-pull@${sitename}.service"],
      Service["grok-fsck@${sitename}.timer"],
    ],
  }

  if $enable_pull {
    $pull_ensure = 'running'
    $pull_enable = true
  } else {
    $pull_ensure = 'stopped'
    $pull_enable = false
  }
  service { "grok-pull@${sitename}.service":
    ensure     => $pull_ensure,
    enable     => $pull_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Package[$grok2::package_name],
  }
  if $enable_fsck {
    $fsck_ensure = 'running'
    $fsck_enable = true
  } else {
    $fsck_ensure = 'stopped'
    $fsck_enable = false
  }
  service { "grok-fsck@${sitename}.timer":
    ensure     => $fsck_ensure,
    enable     => $fsck_enable,
    hasrestart => false,
    hasstatus  => true,
    require    => Package[$grok2::package_name],
  }
}
