require 'test_helper'
require 'file_content'
require 'nickserver/couch_db/response'

class Nickserver::CouchDB::ResponseTest < Minitest::Test
  include FileContent

  def test_404
    response = response_for "bananas@example.org",
      status: 404, body: "{}"
    assert_equal 404, response.status
  end

  def test_200_with_empty_response
    response = response_for "stompy@example.org",
      status: 200, body: file_content(:empty_couchdb_result)
    assert_equal 404, response.status
  end

  def test_200_with_success
    response = response_for "blue@example.org",
      status: 200, body: file_content(:blue_couchdb_result)
    assert_equal 200, response.status
    assert_equal file_content(:blue_nickserver_result), response.content
  end

  def response_for(uid, couch_response = {})
    Nickserver::CouchDB::Response.new uid, couch_response
  end
end
