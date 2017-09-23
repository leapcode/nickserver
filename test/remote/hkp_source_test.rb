require 'test_helper'
require 'support/celluloid_test'
require 'support/http_adapter_helper'
require 'nickserver/hkp/source'

class RemoteHkpSourceTest < CelluloidTest
  include HttpAdapterHelper

  def test_key_info
    uid = 'elijah@riseup.net'
    assert_key_info_for_uid uid do |keys|
      assert_equal 1, keys.size
      assert keys.first.keyid =~ /00440025$/
    end
  end

  def test_tls_validation
    hkp_url = 'https://keys.mayfirst.org/pks/lookup'
    ca_file = file_path('mayfirst-ca.pem')

    config.stub(:hkp_url, hkp_url) do
      # config.stub(:hkp_ca_file, file_path('autistici-ca.pem')) do
      config.stub(:hkp_ca_file, ca_file) do
        assert File.exist?(Nickserver::Config.hkp_ca_file)
        uid = 'elijah@riseup.net'
        assert_key_info_for_uid uid do |keys|
          assert_equal 1, keys.size
          assert keys.first.keyid =~ /00440025$/
        end
      end
    end
  end

  protected

  def assert_key_info_for_uid(uid)
    status, keys = source.search uid
    assert_equal 200, status
    yield keys
  rescue HTTP::ConnectionError => e
    skip "could not talk to hkp server: #{e}"
  end

  def source
    Nickserver::Hkp::Source.new adapter
  end
end
