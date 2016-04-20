require 'spec_helper'

describe 'grokmirror' do
  on_supported_os.each do |os, facts|
    context "on #{os} with defaults for all parameters" do
      it { should compile }
      it { should contain_class('grokmirror::install') }
      it { should contain_package('python-grokmirror') }
      it { should contain_user('grokmirror')
           .with({
             'ensure' => 'present',
             'home'   => '/var/lib/git',
           })
      }
      it { should contain_group('grokmirror')
           .with({
             'ensure' => 'present',
           })
      }
      it { should contain_file('/var/lib/git')
           .with({
             'ensure' => 'directory',
             'owner' => 'root',
             'group' => 'root',
           })
      }
      it { should contain_file('/var/log/grokmirror')
           .with({
             'ensure' => 'directory',
             'owner' => 'grokmirror',
             'group' => 'grokmirror',
           })
      }
    end
    context "on #{os} with different paths, owner, and package name" do
      let(:params) {{
        :global_toplevel => '/home/git',
        :global_logdir => '/var/log/git',
        :package_name => 'python2-grokmirror',
        :user => 'mirror',
        :group => 'mirror',
      }}
      it { should compile }
      it { should contain_class('grokmirror::install') }
      it { should contain_package('python2-grokmirror') }
      it { should contain_user('mirror')
           .with({
             'ensure' => 'present',
             'home'   => '/home/git',
           })
      }
      it { should contain_group('mirror')
           .with({
             'ensure' => 'present',
           })
      }
      it { should contain_file('/home/git')
           .with({
             'ensure' => 'directory',
             'owner' => 'root',
             'group' => 'root',
           })
      }
      it { should contain_file('/etc/grokmirror')
           .with({
             'ensure' => 'directory',
             'owner' => 'root',
             'group' => 'root',
           })
      }
      it { should contain_file('/var/log/git')
           .with({
             'ensure' => 'directory',
             'owner' => 'mirror',
             'group' => 'mirror',
           })
      }
      it { should contain_file('/etc/logrotate.d/grokmirror')
           .with({
             'ensure' => 'present',
             'owner' => 'root',
             'group' => 'root',
           })
           .with_content(/\/var\/log\/git\/\*\.log/)
      }
    end
  end
end

# vi: ts=2 sw=2 sts=2 et :
