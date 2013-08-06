require File.expand_path('test_helper', File.dirname(__FILE__))

class HkpTest < MiniTest::Unit::TestCase

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
    stub_sks_vindex_reponse(uid, :status => 404)
    test_em_errback "Nickserver::HKP::FetchKeyInfo.new.search '#{uid}'" do |error|
      assert_equal 404, error
    end
  end

  def test_key_info_real_network
    real_network do
      uid = 'elijah@riseup.net'
      test_em_callback "Nickserver::HKP::FetchKeyInfo.new.search '#{uid}'" do |keys|
        assert_equal 1, keys.size
        assert keys.first.keyid =~ /00440025$/
      end
    end
  end

  def test_fetch_key
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'
    stub_sks_vindex_reponse(uid, :body => file_content(:leap_vindex_result))
    stub_sks_get_reponse(key_id, :body => file_content(:leap_public_key))

    test_em_callback "Nickserver::HKP::FetchKey.new.get '#{uid}'" do |key_text|
      assert_equal file_content(:leap_public_key), key_text
    end
  end

  def test_fetch_key_not_found
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'

    stub_sks_vindex_reponse(uid, :body => file_content(:leap_vindex_result))
    stub_sks_get_reponse(key_id, :status => 404)

    test_em_errback "Nickserver::HKP::FetchKey.new.get '#{uid}'" do |error|
      assert_equal 404, error
    end
  end

  def test_fetch_key_too_short
    uid    = 'chiiph@leap.se'
    key_id = '9A753A6B'

    stub_sks_vindex_reponse(uid, :body => file_content(:short_key_vindex_result))
    test_em_errback "Nickserver::HKP::FetchKey.new.get '#{uid}'" do |error|
      assert_equal 500, error
    end
  end


  protected

  #
  # Takes a code snippet that returns a Deferrable, and yields the callback result.
  # Assertion fails if errback is called instead of callback.
  #
  # This method takes care of the calls to EM.run and EM.stop. It works kind of like EM.run_block,
  # except I couldn't get run_block to work with multiple nested HTTP requests.
  #
  def test_em_callback(code, &block)
    EM.run do
      deferrable = instance_eval(code)
      deferrable.callback {|response|
        EM.stop
        yield response
        return
      }
      deferrable.errback {|response|
        EM.stop
        flunk "Expecting callback, but errback invoked with response: #{response}"
      }
    end
    assert false, 'should not get here'
  end

  #
  # like test_em_callback, except value yielded is the result of errback, and
  # we raise an exception if errback was not called.
  #
  def test_em_errback(code, &block)
    EM.run do
      deferrable = instance_eval(code)
      deferrable.callback {|response|
        EM.stop
        flunk "Expecting errback, but callback invoked with response: #{response}"
      }
      deferrable.errback {|response|
        EM.stop
        yield response
        return
      }
    end
    assert false, 'should not get here'
  end

  def fetch_key_info(body_source, uid, &block)
    stub_sks_vindex_reponse(uid, :body => file_content(body_source))
    test_em_callback "Nickserver::HKP::FetchKeyInfo.new.search '#{uid}'", &block
  end

end
