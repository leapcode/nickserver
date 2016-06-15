require 'test_helper'
require 'file_content'
require 'nickserver/hkp/v_index_response'

class Nickserver::Hkp::VIndexResponseTest < Minitest::Test
  include FileContent

  def test_leap_public_key
    response = response_for 'cloudadmin@leap.se',
      body: file_content(:leap_vindex_result)
    assert_equal 'E818C478D3141282F7590D29D041EB11B1647490', response.keys.first.keyid
  end

  def response_for(uid, hkp_response = {})
    Nickserver::Hkp::VIndexResponse.new uid, hkp_response
  end
end
