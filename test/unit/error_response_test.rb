require 'test_helper'
require 'nickserver/error_response'

class ErrorResponseTest < Minitest::Test

  def test_content
    response = Nickserver::ErrorResponse.new "Not a valid address"
    assert_equal "500 Not a valid address\n", response.content
    assert_equal 500, response.status
  end

end
