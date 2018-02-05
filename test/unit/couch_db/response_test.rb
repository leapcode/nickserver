require 'test_helper'
require 'file_content'
require 'nickserver/couch_db/response'

class Nickserver::CouchDB::ResponseTest < Minitest::Test
  include FileContent

  def test_404
    response = response_for 'bananas@example.org',
                            status: 404, body: '{}'
    assert_equal 404, response.status
  end

  def test_404_because_of_empty_response
    response = response_for 'stompy@example.org',
                            status: 200,
                            body: file_content(:empty_couchdb_result)
    assert_equal 404, response.status
  end

  def test_200_with_success
    response = response_for 'blue@example.org',
                            status: 200, body:
                            file_content(:blue_couchdb_result)
    assert_equal 200, response.status
    assert_equal JSON.parse(file_content(:blue_nickserver_result)),
      JSON.parse(response.content)
  end

  def test_200_with_other_keys
    body_with_other_type = change_type(file_content(:blue_couchdb_result))
    response = response_for 'blue@example.org',
                            status: 200,
                            body: body_with_other_type
    assert_equal 200, response.status
    expected = JSON.parse change_type(file_content(:blue_nickserver_result))
    assert_equal expected, JSON.parse(response.content)
  end

  def test_openpgp_key_from_old_data_format
    response = response_for 'red@example.org',
                            status: 200,
                            body: file_content(:red_couchdb_result_with_old_format)
    assert_equal 200, response.status
    data = JSON.parse response.content
    assert_includes data.keys, 'address'
    assert_includes data.keys, 'openpgp'
  end

  def test_katzenpost_key
    response = response_for 'red@example.org',
                            status: 200,
                            body: file_content(:red_couchdb_result_with_katzenpost)
    assert_equal 200, response.status
    data = JSON.parse response.content
    assert_includes data.keys, 'address'
    assert_includes data.keys, 'katzenpost_link'
  end

  def response_for(uid, couch_response = {})
    Nickserver::CouchDB::Response.new uid, couch_response
  end

  def change_type(string)
    string.gsub('openpgp', 'other')
  end

end
