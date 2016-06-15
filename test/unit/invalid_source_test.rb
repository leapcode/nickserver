require 'test_helper'
require 'nickserver/invalid_source'

class Nickserver::InvalidSourceTest < Minitest::Test

  def test_query
    adapter.query(nil) do |status, content|
      assert_equal 500, status
      assert_equal "Not a valid address", content
    end
  end

  def adapter
    Nickserver::InvalidSource.new
  end
end
