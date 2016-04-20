require 'spec_helper'
describe 'grokmirror' do
  on_supported_os.each do |os, facts|
    context "on #{os} with defaults for all parameters" do
      it { should compile }
      it { should contain_class('grokmirror') }
    end
  end
end

# vi: ts=2 sw=2 sts=2 et :
