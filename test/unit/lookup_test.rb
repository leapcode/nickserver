require 'test_helper'
require 'minitest/mock'
require 'nickserver/lookup'

class TestLookup < Nickserver::Lookup

  def query
    yield 200, 'yeah'
  end

end

class LookupTest < Minitest::Test

  def test_responding
    responder = Minitest::Mock.new
    responder.expect :send_response, nil,
      [{status: 200, content: 'yeah'}]
    lookup = TestLookup.new nil
    lookup.respond_with responder
    responder.verify
  end
end
