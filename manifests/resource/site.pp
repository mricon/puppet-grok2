define grokmirror::resource::site (

  Enum['present','absent']  $ensure         = 'present',
  Pattern['^\/']            $toplevel       = "${grokmirror::global_toplevel}/${name}",
  Pattern['^\/']            $local_manifest = "${toplevel}/manifest.js.gz",

  Boolean                   $pull_enable                 = true,
  Pattern['^\/.*\.conf$']   $pull_configfile             = "${grokmirror::global_configdir}/${name}-repos.conf",
  Pattern['^\/.*\.log$']    $pull_logfile                = "${grokmirror::global_logdir}/${name}-pull.log",
  Enum['debug','info']      $pull_loglevel               = $grokmirror::global_loglevel,
  Pattern['^https?:\/\/','^file:\/\/']
                            $pull_remote_manifest        = undef,
  Pattern['^git:\/\/','^file:\/\/', '^https?:\/\/']
                            $pull_site_url               = undef,
  String                    $pull_default_owner          = 'Grokmirror',
  Boolean                   $pull_ignore_repo_references = false,
  Pattern['^\/']            $pull_projectslist           = "${toplevel}/projects.list",
  Optional[String]          $pull_projectslist_trimtop   = undef,
  Boolean                   $pull_projectslist_symlinks  = false,
  Optional[Pattern['^\/']]  $pull_post_update_hook       = undef,
  Integer[5,100]            $pull_purgeprotect           = 5,
  Integer[1,100]            $pull_threads                = 5,
  Array[String]             $pull_include                = ['*'],
  Optional[Array[String]]   $pull_exclude                = undef,
  Boolean                   $pull_enable_cron            = true,
  String                    $pull_cron_minute            = '*/5',
  String                    $pull_cron_hour              = '*',
  String                    $pull_cron_month             = '*',
  String                    $pull_cron_monthday          = '*',
  String                    $pull_cron_weekday           = '*',
  String                    $pull_cron_extra_flags       = '-p',

  Boolean                   $fsck_enable                 = true,
  Pattern['^\/.*\.conf$']   $fsck_configfile             = "${grokmirror::global_configdir}/${name}-fsck.conf",
  Pattern['^\/.*\.log$']    $fsck_logfile                = "${grokmirror::global_logdir}/${name}-fsck.log",
  Enum['debug','info']      $fsck_loglevel               = $grokmirror::global_loglevel,
  Pattern['^\/']            $fsck_lockfile               = "${toplevel}/.fsck.lock",
  Pattern['^\/']            $fsck_statusfile             = "${toplevel}/.fsck-status.js",
  Integer[2,365]            $fsck_frequency              = 30,
  Boolean                   $fsck_repack                 = true,
  String                    $fsck_repack_flags           = '-Adlq',
  Integer[2,100]            $fsck_full_repack_every      = 10,
  String                    $fsck_full_repack_flags      = '-Adlfq --window=200 --depth=50',
  Boolean                   $fsck_prune                  = true,
  Boolean                   $fsck_enable_cron            = true,
  String                    $fsck_cron_minute            = '0',
  String                    $fsck_cron_hour              = '4',
  String                    $fsck_cron_month             = '*',
  String                    $fsck_cron_monthday          = '*',
  String                    $fsck_cron_weekday           = 'sun',
  String                    $fsck_cron_extra_flags       = '',

  Array[String]             $fsck_ignore_errors          = [
    'dangling commit',
    'dangling blob',
    'notice: HEAD points to an unborn branch',
    'notice: No default references',
    'contains zero-padded file modes'
  ],
) {

  # We create this if we are asked to be present, but we don't delete it
  # because we don't want to inadvertently delete git repos
  if $ensure == 'present' {
    file { $toplevel:
      ensure  => 'directory',
      owner   => $grokmirror::user,
      group   => $grokmirror::group,
      mode    => '0755',
      require => [
        File[$grokmirror::global_toplevel],
      ],
    }
  }

  if $pull_enable {
    file { $pull_configfile:
      ensure   => $ensure,
      owner    => 'root',
      group    => 'root',
      mode     => '0644',
      content  => template('grokmirror/site/repos.conf.erb'),
      checksum => 'md5',
    }

    cron { "${name}-grok-pull":
      ensure      => $ensure,
      command     => "${grokmirror::pull_command} ${pull_cron_extra_flags} -c ${pull_configfile}",
      environment => $grokmirror::cron_environment,
      minute      => $pull_cron_minute,
      hour        => $pull_cron_hour,
      month       => $pull_cron_month,
      monthday    => $pull_cron_monthday,
      weekday     => $pull_cron_weekday,
      user        => $grokmirror::user,
      require     => [
        User[$grokmirror::user],
        File[$pull_configfile],
      ],
    }
  }

  if $fsck_enable {
    file { $fsck_configfile:
      ensure   => $ensure,
      owner    => 'root',
      group    => 'root',
      mode     => '0644',
      content  => template('grokmirror/site/fsck.conf.erb'),
      checksum => 'md5',
    }

    cron { "${name}-grok-fsck":
      ensure      => $ensure,
      command     => "${grokmirror::fsck_command} ${fsck_cron_extra_flags} -c ${fsck_configfile}",
      environment => $grokmirror::cron_environment,
      minute      => $fsck_cron_minute,
      hour        => $fsck_cron_hour,
      month       => $fsck_cron_month,
      monthday    => $fsck_cron_monthday,
      weekday     => $fsck_cron_weekday,
      user        => $grokmirror::user,
      require     => [
        User[$grokmirror::user],
        File[$fsck_configfile],
      ],
    }
  }

}
