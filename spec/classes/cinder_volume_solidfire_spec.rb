require 'spec_helper'

describe 'cinder::volume::solidfire' do
  let :req_params do
    {
      :san_ip       => '127.0.0.2',
      :san_login    => 'solidfire',
      :san_password => 'password',
    }
  end

  let :params do
    req_params
  end

  describe 'solidfire volume driver' do
    it 'configure solidfire volume driver' do
      is_expected.to contain_cinder_config('DEFAULT/volume_driver').with_value('cinder.volume.drivers.solidfire.SolidFireDriver')
      is_expected.to contain_cinder_config('DEFAULT/san_ip').with_value('127.0.0.2')
      is_expected.to contain_cinder_config('DEFAULT/san_login').with_value('solidfire')
      is_expected.to contain_cinder_config('DEFAULT/san_password').with_value('password')
      is_expected.to contain_cinder_config('DEFAULT/sf_template_account_name').with_value('openstack-vtemplate')
      is_expected.to contain_cinder_config('DEFAULT/sf_allow_template_caching').with_value('false')
    end

    it 'marks san_password as secret' do
      is_expected.to contain_cinder_config('DEFAULT/san_password').with_secret( true )
    end

  end

  describe 'solidfire volume driver with additional configuration' do
    before :each do
      params.merge!({:extra_options => {'solidfire_backend/param1' => {'value' => 'value1'}}})
    end

    it 'configure solidfire volume with additional configuration' do
      is_expected.to contain_cinder__backend__solidfire('DEFAULT').with({
        :extra_options => {'solidfire_backend/param1' => {'value' => 'value1'}}
      })
    end
  end

end
