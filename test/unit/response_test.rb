require 'test_helper'
require 'nickserver/response'

class ResponseTest < Minitest::Test

  def test_content
    response = Nickserver::Response.new 500, "Not a valid address"
    assert_equal "500 Not a valid address", response.content
  end

end
