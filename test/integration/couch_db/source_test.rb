require 'test_helper'
require 'file_content'
require 'helpers/test_adapter'
require 'nickserver/couch_db/source'

module Nickserver::CouchDB
  class SourceTest < Minitest::Test
  include FileContent

    def test_couch_query_and_response
      adapter = TestAdapter.new 200, file_content(:blue_couchdb_result)
      source = Source.new adapter
      source.query 'blue@example.org' do |response|
        assert_equal 200, response.status
        assert_equal file_content(:blue_nickserver_result), response.content
      end
    end
  end
end
