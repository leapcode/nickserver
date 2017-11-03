require 'test_helper'
require 'support/http_stub_helper'
require 'nickserver/hkp/source'

class HkpTest < Minitest::Test
  include HttpStubHelper

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
    stubbing_http do
      uid = 'leaping_lemur@leap.se'
      stub_sks_vindex_reponse(uid, status: 404)
      assert_nil response_for_uid(uid)
    end
  end

  def test_no_matching_key_found
    stubbing_http do
      uid = 'leaping_lemur@leap.se'
      stub_sks_vindex_reponse(uid, status: 200)
      assert_nil response_for_uid(uid)
    end
  end

  def test_fetch_key
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'
    stubbing_http do
      stub_sks_vindex_reponse(uid, body: file_content(:leap_vindex_result))
      stub_sks_get_reponse(key_id, body: file_content(:leap_public_key))
      response = response_for_uid(uid)
      content = JSON.parse response.content
      assert_equal file_content(:leap_public_key), content['openpgp']
    end
  end

  def test_fetch_key_not_found
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'

    stubbing_http do
      stub_sks_vindex_reponse(uid, body: file_content(:leap_vindex_result))
      stub_sks_get_reponse(key_id, status: 404)
      assert_equal 404, response_for_uid(uid).status
    end
  end

  def test_fetch_key_too_short
    uid = 'chiiph@leap.se'

    stubbing_http do
      stub_sks_vindex_reponse(uid, body: file_content(:short_key_vindex_result))
      assert_equal 500, response_for_uid(uid).status
    end
  end

  protected

  def response_for_uid(uid)
    Nickserver::Hkp::Source.new(adapter).query uid
  end

  def assert_key_info_for_uid(uid)
    status, keys = Nickserver::Hkp::Source.new(adapter).search uid
    assert_equal 200, status
    yield keys
  end

  def fetch_key_info(body_source, uid, &block)
    stubbing_http do
      stub_sks_vindex_reponse uid, body: file_content(body_source)
      assert_key_info_for_uid(uid, &block)
    end
  end
end
