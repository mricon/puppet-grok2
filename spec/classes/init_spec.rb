require 'spec_helper'

describe 'grokmirror' do
  on_supported_os.each do |os, facts|
    context "on #{os} with defaults for all parameters" do
      it { should compile }
      it { should contain_class('grokmirror') }
    end
    context "on #{os} with different paths and example sites" do
      let(:params) {{
        :global_toplevel => '/home/git',
        :global_logdir => '/var/log/git',
        :sites => { 'example' => 
                    { 'pull_remote_manifest' => 'http://example.com/manifest.js',
                      'pull_site_url' => 'git://git.example.com'
                    }
        }
      }}
      it { should compile }
      it { should contain_file('/etc/grokmirror/example-repos.conf')
           .with_content(/\[example\]/)
           .with_content(/site\s*=\s*git:\/\/git\.example\.com/)
           .with_content(/manifest\s*=\s*http:\/\/example\.com\/manifest.js/)
           .with_content(/toplevel\s*=\s*\/home\/git\/example/)
           .with_content(/mymanifest\s*=\s*\/home\/git\/example\/manifest\.js\.gz/)
           .with_content(/log\s*=\s*\/var\/log\/git\/example-pull.log/)
      }
      it { should contain_file('/etc/grokmirror/example-fsck.conf')
           .with_content(/\[example\]/)
           .with_content(/manifest\s*=\s*\/home\/git\/example\/manifest\.js\.gz/)
           .with_content(/toplevel\s*=\s*\/home\/git\/example/)
           .with_content(/log\s*=\s*\/var\/log\/git\/example-fsck.log/)
           .with_content(/statusfile\s*=\s*\/home\/git\/example\/\.fsck-status\.js/)
           .with_content(/lock\s*=\s*\/home\/git\/example\/\.fsck\.lock/)
      }
      it { should contain_file('/home/git/example')
           .with(
             'owner' => 'grokmirror',
             'group' => 'grokmirror',
           )
      }
      it { should contain_cron('example-grok-pull')
           .with(
             'user' => 'grokmirror',
             'command' => '/usr/bin/grok-pull -p -c /etc/grokmirror/example-repos.conf',
           )
      }
      it { should contain_cron('example-grok-fsck')
           .with(
             'user' => 'grokmirror',
             'command' => '/usr/bin/grok-fsck  -c /etc/grokmirror/example-fsck.conf',
           )
      }
    end
  end
end

# vi: ts=2 sw=2 sts=2 et :
