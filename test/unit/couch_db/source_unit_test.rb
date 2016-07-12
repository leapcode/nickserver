require 'test_helper'
require 'nickserver/couch_db/source'

module Nickserver::CouchDB
  class SourceUnitTest < Minitest::Test

    def test_query
      address = "nick@domain.tl"
      adapter = Minitest::Mock.new
      adapter.expect :get, [200, nil],
        [String,  {query: { reduce: "false", key: "\"#{address}\"" }}]
      Source.new(adapter).query address
      adapter.verify
    end
  end
end
