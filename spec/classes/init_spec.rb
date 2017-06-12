require 'spec_helper'
describe 'mount_windows_smb' do
  context 'with default values for all parameters' do
    it { should contain_class('mount_windows_smb') }
  end
end
