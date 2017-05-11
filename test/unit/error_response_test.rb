require 'test_helper'
require 'nickserver/error_response'
require 'json'

class ErrorResponseTest < Minitest::Test

  def test_content
    response = Nickserver::ErrorResponse.new "Not a valid address"
    assert_equal 400, response.status
    assert_equal JSON.generate(error: "Not a valid address"),
      response.content
  end

end
