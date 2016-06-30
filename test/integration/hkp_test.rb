require 'test_helper'
require 'nickserver/hkp/source'
require 'nickserver/adapters/celluloid_http'

class HkpTest < Minitest::Test

  def test_key_info_expired
    fetch_key_info(:hkp_vindex_result, 'lemur@leap.se') do |keys|
      assert_equal 1, keys.length, 'should find a single key'
      assert_equal ['lemur@example.org', 'lemur@leap.se'].sort, keys.first.uids.sort, 'should find both uids'
      assert_equal '0EE5BE979282D80B9F7540F1CCD2ED94D21739E9', keys.first.keyid
    end
  end

  def test_key_info_multiple_valid_results
    fetch_key_info :hkp_vindex_result, 'gazelle@leap.se' do |keys|
      assert_equal 2, keys.length, 'should find two keys'
      assert_equal ['gazelle@leap.se'], keys.first.uids
      assert_equal '3790027A', keys.first.keyid
      assert keys.last.uids.include? 'gazelle@leap.se'
    end
  end

  def test_key_info_reject_keysize
    fetch_key_info :hkp_vindex_result, 'frog@leap.se' do |keys|
      assert_equal 1, keys.length, 'should find one key' # because short key gets ignored
      assert_equal '00440025', keys.first.keyid
    end
  end

  def test_key_info_not_found
    uid = 'leaping_lemur@leap.se'
    stub_sks_vindex_reponse(uid, status: 404)
    assert_response_status_for_uid uid, 404
  end

  def test_no_matching_key_found
    uid = 'leaping_lemur@leap.se'
    stub_sks_vindex_reponse(uid, status: 200)
    assert_response_status_for_uid uid, 404
  end

  def test_fetch_key
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'
    stub_sks_vindex_reponse(uid, body: file_content(:leap_vindex_result))
    stub_sks_get_reponse(key_id, body: file_content(:leap_public_key))

    assert_response_for_uid(uid) do |response|
      content = JSON.parse response.content
      assert_equal file_content(:leap_public_key), content['openpgp']
    end
  end

  def test_fetch_key_not_found
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'

    stub_sks_vindex_reponse(uid, body: file_content(:leap_vindex_result))
    stub_sks_get_reponse(key_id, status: 404)

    assert_response_status_for_uid uid, 404
  end

  def test_fetch_key_too_short
    uid    = 'chiiph@leap.se'

    stub_sks_vindex_reponse(uid, body: file_content(:short_key_vindex_result))
    assert_response_status_for_uid uid, 500
  end

  #
  # real network tests
  # remember: must be run with REAL_NET=true
  #

  def test_key_info_real_network
    real_network do
      uid = 'elijah@riseup.net'
      assert_key_info_for_uid uid do |keys|
        assert_equal 1, keys.size
        assert keys.first.keyid =~ /00440025$/
      end
    end
  end

  def test_tls_validation_with_real_network
    hkp_url = 'https://keys.mayfirst.org/pks/lookup'
    ca_file = file_path('mayfirst-ca.pem')

    real_network do
      config.stub(:hkp_url, hkp_url) do
        config.stub(:hkp_ca_file, ca_file) do
        #config.stub(:hkp_ca_file, file_path('autistici-ca.pem')) do
          assert File.exist?(Nickserver::Config.hkp_ca_file)
          uid = 'elijah@riseup.net'
          assert_key_info_for_uid uid do |keys|
            assert_equal 1, keys.size
            assert keys.first.keyid =~ /00440025$/
          end
        end
      end
    end
  end

  protected

  def assert_response_status_for_uid(uid, status)
    assert_response_for_uid(uid) do |response|
      assert_equal status, response.status
    end
  end

  def assert_response_for_uid(uid, &block)
    Nickserver::Hkp::Source.new(adapter).query uid do |response|
      yield response
    end
  end

  def assert_key_info_for_uid(uid, &block)
    Nickserver::Hkp::Source.new(adapter).search uid do |status, keys|
      assert_equal 200, status
      yield keys
    end
  end

  def adapter
    Nickserver::Adapters::CelluloidHttp.new
  end

  def fetch_key_info(body_source, uid, &block)
    stub_sks_vindex_reponse(uid, body: file_content(body_source))
    assert_key_info_for_uid(uid, &block)
  end

end
