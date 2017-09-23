require 'test_helper'
require 'nickserver/response'

class ResponseTest < Minitest::Test
  def test_ok_response
    response = Nickserver::Response.new 200, 'content'
    assert_equal 'content', response.content
    assert_equal 200, response.status
  end
end
