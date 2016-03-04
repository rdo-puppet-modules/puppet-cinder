require 'puppet/util/inifile'
require 'puppet/provider/openstack'
require 'puppet/provider/openstack/auth'
require 'puppet/provider/openstack/credentials'

class Puppet::Provider::Cinder < Puppet::Provider::Openstack

  extend Puppet::Provider::Openstack::Auth

  def self.conf_filename
    '/etc/cinder/cinder.conf'
  end

  def self.cinder_conf
    return @cinder_conf if @cinder_conf
    @cinder_conf = Puppet::Util::IniConfig::File.new
    @cinder_conf.read(conf_filename)
    @cinder_conf
  end

  def self.request(service, action, properties=nil)
    begin
      super
    rescue Puppet::Error::OpenstackAuthInputError, Puppet::Error::OpenstackUnauthorizedError => error
      cinder_request(service, action, error, properties)
    end
  end

  def self.cinder_request(service, action, error, properties=nil)
    properties ||= []
    @credentials.username = cinder_credentials['admin_user']
    @credentials.password = cinder_credentials['admin_password']
    @credentials.project_name = cinder_credentials['admin_tenant_name']
    @credentials.auth_url = auth_endpoint
    raise error unless @credentials.set?
    Puppet::Provider::Openstack.request(service, action, properties, @credentials)
  end

  def self.cinder_credentials
    @cinder_credentials ||= get_cinder_credentials
  end

  def cinder_credentials
    self.class.cinder_credentials
  end

  def self.get_cinder_credentials
    auth_keys = ['auth_uri', 'admin_tenant_name', 'admin_user',
                 'admin_password']
    conf = cinder_conf
    if conf and conf['keystone_authtoken'] and
        auth_keys.all?{|k| !conf['keystone_authtoken'][k].nil?}
      creds = Hash[ auth_keys.map \
                   { |k| [k, conf['keystone_authtoken'][k].strip] } ]
      return creds
    else
      raise(Puppet::Error, "File: #{conf_filename} does not contain all " +
            "required sections. Cinder types will not work if cinder is not " +
            "correctly configured.")
    end
  end

  def self.get_auth_endpoint
    q = cinder_credentials
    "#{q['auth_uri']}"
  end

  def self.auth_endpoint
    @auth_endpoint ||= get_auth_endpoint
  end

  def self.reset
    @cinder_conf = nil
    @cinder_credentials = nil
  end
end
