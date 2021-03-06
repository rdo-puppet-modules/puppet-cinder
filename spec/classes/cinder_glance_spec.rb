#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for cinder::glance class
#

require 'spec_helper'

describe 'cinder::glance' do

  let :default_params do
    { :glance_api_version         => '2',
      :glance_num_retries         => '<SERVICE DEFAULT>',
      :glance_api_insecure        => '<SERVICE DEFAULT>',
      :glance_api_ssl_compression => '<SERVICE DEFAULT>',
      :glance_request_timeout     => '<SERVICE DEFAULT>' }
  end

  let :params do
    {}
  end

  shared_examples_for 'cinder with glance' do
    let :p do
      default_params.merge(params)
    end

    it 'configures cinder.conf with default params' do
      is_expected.to contain_cinder_config('DEFAULT/glance_api_version').with_value(p[:glance_api_version])
      is_expected.to contain_cinder_config('DEFAULT/glance_num_retries').with_value(p[:glance_num_retries])
      is_expected.to contain_cinder_config('DEFAULT/glance_api_insecure').with_value(p[:glance_api_insecure])
      is_expected.to contain_cinder_config('DEFAULT/glance_api_ssl_compression').with_value(p[:glance_api_ssl_compression])
      is_expected.to contain_cinder_config('DEFAULT/glance_request_timeout').with_value(p[:glance_request_timeout])
    end

     context 'configure cinder with one glance server' do
       before :each do
        params.merge!(:glance_api_servers => '10.0.0.1:9292')
       end
       it 'should configure one glance server' do
         is_expected.to contain_cinder_config('DEFAULT/glance_api_servers').with_value(p[:glance_api_servers])
       end
     end

     context 'configure cinder with two glance servers' do
       before :each do
        params.merge!(:glance_api_servers => ['10.0.0.1:9292','10.0.0.2:9292'])
       end
       it 'should configure two glance servers' do
         is_expected.to contain_cinder_config('DEFAULT/glance_api_servers').with_value(p[:glance_api_servers].join(','))
       end
     end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({:processorcount => 8}))
      end

      it_configures 'cinder with glance'
    end
  end

end
