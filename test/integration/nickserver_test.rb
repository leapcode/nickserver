require 'test_helper'
require 'json'

#
# Some important notes to understanding these tests:
#
# (1) Requests to 127.0.0.1 always bypass HTTP stub.
#
# (2) All requests to nickserver are to 127.0.0.1.
#
# (3) the "Host" header for requests to nickserver must be set (or Config.domain set)
#
# (4) When stubbing requests to couchdb, the couchdb host is changed from the
# default (127.0.0.1) to a dummy value (notlocalhost).
#

class NickserverTest < Minitest::Test

  def setup
    super
    Celluloid.shutdown; Celluloid.boot
  end

  def test_GET_served_via_SKS
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'
    stub_sks_vindex_reponse(uid, body: file_content(:leap_vindex_result))
    stub_sks_get_reponse(key_id, body: file_content(:leap_public_key))

    start do
      params = {query: {"address" => uid}}
      get(params) do |response|
        assert_equal file_content(:leap_public_key), JSON.parse(response.to_s)["openpgp"]
      end
    end
  end

  def test_POST_served_via_SKS
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'
    stub_sks_vindex_reponse(uid, body: file_content(:leap_vindex_result))
    stub_sks_get_reponse(key_id, body: file_content(:leap_public_key))

    start do
      params = {body: {"address" => uid}}
      post(params) do |response|
        assert_equal file_content(:leap_public_key), JSON.parse(response.to_s)["openpgp"]
      end
    end
  end

  def test_GET_served_via_couch_not_found
    domain = "example.org"
    uid    = "bananas@" + domain
    stub_couch_response(uid, status: 404) do
      start do
        params = {query: {"address" => uid}, head: {"Host" => domain}}
        get(params) do |response|
          assert_equal 404, response.code
        end
      end
    end
  end

  def test_GET_served_via_couch_empty_results
    domain = "example.org"
    uid    = "stompy@" + domain
    stub_couch_response(uid, body: file_content(:empty_couchdb_result)) do
      start do
        params = {query: {"address" => uid}, head: {host: domain}}
        get(params) do |response|
          assert_equal 404, response.code
        end
      end
    end
  end

  def test_GET_served_via_couch_success
    domain = "example.org"
    uid    = "blue@" + domain
    stub_couch_response(uid, body: file_content(:blue_couchdb_result)) do
      start do
        params = {query: {"address" => uid}, head: {"Host" => domain}}
        get(params) do |response|
          assert_equal file_content(:blue_nickserver_result), response.to_s
        end
      end
    end
  end

  def test_GET_empty
    start do
      get({}) do |response|
        assert_equal "404 Not Found\n", response.to_s
      end
    end
  end

  protected

  #
  # start nickserver
  #
  def start(timeout = 1)
    server = Nickserver::ReelServer.new '127.0.0.1', config.port
    yield server
  ensure
    server.terminate if server && server.alive?
  end

  #
  # http GET requests to nickserver
  #
  def get(options = {}, &block)
    request(:get, params: options[:query], head: options[:head], &block)
  end

  #
  # http POST requests to nickserver
  #
  def post(options, &block)
    request(:post, params: options[:body], head: options[:head], &block)
  end

  #
  # http request to nickserver
  #
  # this works because http requests to 127.0.0.1 are not stubbed, but requests to other domains are.
  #
  def request(method, options = {})
    response = HTTP.
      headers(options.delete(:head)).
      request method, "http://127.0.0.1:#{config.port}/", options
    yield response
  end

end
