$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'kernel_ext'
require 'bundler/setup'
require 'minitest/autorun'
silence_warnings do
  require 'webmock/minitest'
end
require 'celluloid/test'
require 'nickserver'
require 'minitest/pride'
require 'minitest/hell'

TESTING = true

class Minitest::Test
  # Add global extensions to the test case class here

  def setup
    Nickserver::Config.load

    # by default, mock all non-localhost network connections
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  def file_content(filename)
    (@file_contents ||= {})[filename] ||= File.read(file_path(filename))
  end

  def file_path(filename)
    "%s/files/%s" % [File.dirname(__FILE__), filename]
  end

  def real_network
    unless ENV['ONLY_LOCAL'] == 'true'
      WebMock.allow_net_connect!
      yield
      WebMock.disable_net_connect!
    end
  end

  def stub_sks_vindex_reponse(uid, opts = {})
    options = {status: 200, body: ""}.merge(opts)
    stub_http_request(:get, Nickserver::Config.hkp_url).with(
      query: {op: 'vindex', search: uid, exact: 'on', options: 'mr', fingerprint: 'on'}
    ).to_return(options)
  end

  def stub_sks_get_reponse(key_id, opts = {})
    options = {status: 200, body: ""}.merge(opts)
    stub_http_request(:get, config.hkp_url).with(
      query: {op: 'get', search: "0x"+key_id, exact: 'on', options: 'mr'}
    ).to_return(options)
  end

  def stub_couch_response(uid, opts = {})
    # can't stub localhost, so set couch_host to anything else
    config.stub :couch_host, 'notlocalhost' do
      options = {status: 200, body: ""}.merge(opts)
      query = "\?key=#{"%22#{uid}%22"}&reduce=false"
      stub_http_request(:get, /#{Regexp.escape(config.couch_url)}.*#{query}/).to_return(options)
      yield
    end
  end

  def config
    Nickserver::Config
  end
end
