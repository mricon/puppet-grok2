# grokmirror #

#### Table of Contents

1. [Overview](#overview)
2. [Usage - Basic usage](#usage)
3. [Reference - Configuration options](#reference)
3. [Limitations - OS compatibility, etc.](#limitations)

## Overview

[![Build Status](https://travis-ci.org/mricon/puppet-grokmirror.png)](https://travis-ci.org/mricon/puppet-grokmirror)

A Puppet module for managing deployments of
[Grokmirror](https://github.com/mricon/grokmirror) - the smart way
to mirror large git repository collections

## Usage

To use this module you can either directly include it in your module
tree, or add the following to your `Puppetfile`:

```
  mod 'mricon-grokmirror'
```

A node should then be assigned the relevant grokmirror classes. You *must*
pass a sites hash with at least one site configuration. E.g. for mirroring
kernel.org git repositories:

```puppet
  class { 'grokmirror':
    sites => {
      'kernelorg': {
        pull_remote_manifest => 'https://git.kernel.org/manifest.js.gz',
        pull_site_url => 'git://git.kernel.org',
        pull_include => [
          '/pub/scm/linux/kernel/git/torvalds/*',
          '/pub/scm/linux/kernel/git/stable/*',
        ],
      }
    }
  }
```

If you're using Hiera, the same configuration might look like:

```yaml
  grokmirror::sites:
    'kernelorg':
      pull_remote_manifest: 'https://git.kernel.org/manifest.js.gz'
      pull_site_url: 'git://git.kernel.org'
      pull_include:
        - '/pub/scm/linux/kernel/git/torvalds/*'
        - '/pub/scm/linux/kernel/git/stable/*'
```

## Reference

### `grokmirror`

#### `package_name`

Name of the package to install.

Default: `python-grokmirror`

#### `package_ensure`

In case you are not running grokmirror from a package, you can set this to
`absent`.

Default: `present`

#### `global_configdir`

Where the configuration files for sites should be created. You can override
site-specific config file locations in the site config.

Default: `/etc/grokmirror`

#### `global_toplevel`

Where the repositories for each site are going to be placed. E.g. for a site
named `kernelorg`, the location will be `global_toplevel/kernelorg`. You can
override site-specific toplevel locations in the site config.

Default: `/var/lib/git`

#### `global_logdir`

Where to keep the log files. E.g. for a site named `kernelorg`, the logfiles
will be `global_logdir/kernelorg-pull.log` and
`global_logdir/kernelorg-fsck.log`. You can override site-specific logfile
locations in the site config, but you will need to provide your own logrotate
handlers.

Default: `/var/log/grokmirror`

#### `global_loglevel`

Loglevel that is inherited by all sites; can be `debug` or `info`. You can
override site-specific loglevel setting in the site config.

Default: `info`

#### `user`

User that owns the repositories and runs the pull/fsck scripts.

Default: `grokmirror`

#### `manage_user`

Whether to manage the user (set to false if the user is created by another
module or is pre-existing).

Default: `true`

#### `group`

Group that owns the repositories.

Default: `grokmirror`

#### `manage_group`

Whether to manage the group (set to false if the user is created by another
module or is pre-existing).

Default: `true`

#### `pull_command`

The command that executes `grok-pull`. If you installed from a package, this
will be `/usr/bin/grok-pull`, but if you are running from a git repository,
you can override it here.

Default: `/usr/bin/grok-pull`

#### `fsck_command`

The command that executes `grok-fsck`. If you installed from a package, this
will be `/usr/bin/grok-fsck`, but if you are running from a git repository,
you can override it here.

Default: `/usr/bin/grok-fsck`

#### `cron_environment`

The environment to pass to the cron scripts.

Default: `PATH=/bin:/usr/bin`

### grokmirror::sites

#### `ensure`

If `present`, configures a site, and if `absent`, will remove the site
configuration and cronjobs, but **not** the mirrored repositories or logfiles.

Default: `present`

#### `toplevel`

Where the repositories for this site will be mirrored.

Default: `global_toplevel/sitename`

#### `local_manifest`

Where to save the local copy of the manifest.

Default: `toplevel/manifest.js.gz`

#### `pull_enable`

Whether to enable the grok-pull configuration. Sometimes you just want to
enable frok-fsck runs (e.g. on a git master).

Default: `true`

#### `pull_configfile`

Where to create the config file.

Default: `global_configdir/sitename-repos.conf`

#### `pull_logfile`

Where to store the grok-pull log.

Default: `global_logdir/sitename-pull.log`

#### `pull_loglevel`

Can be used to override global_loglevel. Must be `info` or `debug`.

Default: `info`

#### `pull_remote_manifest`

Where the remote manifest for the repositories we are mirroring is located.
One of the two required settings that must be provided. E.g. for kernel.org,
it is `https://git.kernel.org/manifest.js.gz`.

#### `pull_site_url`

The location of the git server where we are going to be pulling from. E.g. for
kernel.org it is `git://git.kernel.org`.

#### `pull_default_owner`

If the remote repository does not specify the owner (to display in gitweb/cgit
views), set it to this.

Default: `Grokmirror`

#### `pull_ignore_repo_references`

Never clone with `--reference` and always create independent clones with no
alternates. Safer, but requires dramatically more disk space. Good for
backups.

Default: `false`

#### `pull_projectslist`

Where to create the projects.list for cgit needs.

Default: `toplevel/projects.list`

#### `pull_projectslist_trimtop`

See grokmirror documentation for explanation.

Default: `undef`

#### `pull_projectslist_symlinks`

See grokmirror documentation for explanation.

Default: `false`

#### `pull_post_update_hook`

After a repository is updated, run this script. See grokmirror documentation
for full details.

Default: `undef`

#### `pull_purgeprotect`

If `-p` is passed, grokmirror will refuse to purge repositories if more than
this percentage of them is to be deleted. A good protection in case the master
provided an empty manifest or manifest with greatly reduced list of
repositories.

Default: `5`

#### `pull_threads`

How many `git remote update` processes to create in parallel. Shouldn't be
larger than how many processor threads you have, and requires good random
access disk IO speeds.

Default: `5`

#### `pull_include`

An Array of strings containing shell-globbed list of repos to include in the
slave mirror. See grokmirror documentation for full details.

Default: `['*']`

#### `pull_exclude`

An Array of strings containing shell-globbed list of repos to exclude from the
mirror. See grokmirror documentation for full details.

Default: `undef`

#### `pull_enable_cron`

Whether to enable the cronjob running `grok-pull` on a regular basis. You
probably want this, unless you want to only update the mirror on an ad-hoc
manual basis. Default is to run `grok-pull` every 5 minutes.

Default: `true`

#### `pull_cron_minute`

Minutes parameter to pass to cron (must be a String). Can be anything cron
understands, e.g. `*/5` for "every 5 minutes", `*/20` for every 20 minutes,
etc.

Default: `*/5`

#### `pull_cron_hour`

The "hour" parameter to pass to cron (must be a String).

Default: `*`

#### `pull_cron_month`

The "month" parameter to pass to cron (must be a String).

Default: `*`

#### `pull_cron_monthday`

The "day of the month" parameter to pass to cron (must be a String).

Default: `*`

#### `pull_cron_weekday`

The "weekday" parameter to pass to cron (must be a String).

Default: `*`

#### `pull_cron_extra_flags`

You probably want to include the `-p` flag by default, unless you specifically
do NOT want to purge as part of the regular cron run (e.g. if you have
thousands of repositories and this is too much of a IO hit). If so, set to
`undef` or empty string.

Default: `-p`

#### `fsck_enable`

Whether to enable the grok-fsck configuration. You probably always want to do
that if you're doing grok-pull, otherwise your repos will never get repacked
and pruned.

Default: `true`

#### `fsck_configfile`

Where to create the grok-fsck config file.

Default: `global_configdir/sitename-fsck.conf`

#### `fsck_logfile`

Where to store the grok-fsck log.

Default: `global_logdir/sitename-fsck.log`

#### `fsck_loglevel`

Can be used to override global_loglevel. Must be `info` or `debug`.

Default: `info`

#### `fsck_lockfile`

Where to store the lockfile to ensure that only one grok-fsck instance is
running.

Default: `toplevel/.fsck.lock`

#### `fsck_statusfile`

Where to keep the status file for state-tracking between runs.

Default: `toplevel/.fsck-status.js`

#### `fsck_frequency`

How often (roughly) each repository should be fsck'd and repacked/pruned -- in
days. See grokmirror documentation for more details.

Default: `30`

#### `fsck_repack`

Whether to repack the repositories after doing `git fsck`. You almost always
want this on.

Default: `true`

#### `fsck_repack_flags`

The repack flags to use when repacking the repository. If you have newer git
than 2.1, you should also pass `-b --pack-kept-objects` to pre-create bitmaps
for faster "objects counting" stage. See `git-repack` and grokmirror
documentation for more info.

Default: `-Adlq`

#### `fsck_full_repack_every`

Repos should be repacked more thoroughly every now and again, in order to
create better deltas. This setting tells grokmirror how frequently this should
happen (e.g. `10` means that every 10th repack should be a full repack).

Default: `10`

#### `fsck_full_repack_flags`

What flags to use during full repack. You want to always include `-f` and
probably a larger window/depth.

Default: `-Adlfq --window=200 --depth=50`

#### `fsck_prune`

Whether to prune the repos after repacking (you almost always want this).

Default: `true`

#### `fsck_enable_cron`

Whether to enable the cronjob running `grok-fsck` on a regular basis. You
probably want this, unless you want to only run it manually on an ad-hoc
basis. Default is to run it every Sunday at 4AM system time.

Default: `true`

#### `fsck_cron_minute`

Minutes parameter to pass to cron (must be a String).

Default: `0`

#### `fsck_cron_hour`

The "hour" parameter to pass to cron (must be a String).

Default: `4`

#### `fsck_cron_month`

The "month" parameter to pass to cron (must be a String).

Default: `*`

#### `fsck_cron_monthday`

The "day of the month" parameter to pass to cron (must be a String).

Default: `*`

#### `fsck_cron_weekday`

The "weekday" parameter to pass to cron (must be a String).

Default: `sun`

#### `fsck_cron_extra_flags`

Any additional flags to pass to `grok-fsck` (none at this time).

Default: `undef`

#### `fsck_ignore_errors`

If `git fsck` reports benign errors, you can list the match substrings in this
array to ignore things you don't really care about (like dangling commits).

Default:
```puppet
  [
    'dangling commit',
    'dangling blob',
    'notice: HEAD points to an unborn branch',
    'notice: No default references',
    'contains zero-padded file modes'
  ]
```

## Limitations

Tested on RHEL 6/7 and CentOS 6/7. Not tested anywhere else. :)
