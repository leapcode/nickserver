require 'test_helper'
require 'support/http_stub_helper'
require 'nickserver/server'
require 'json'

#
# Some important notes to understanding these tests:
#
# (1) We mock the http adapter. So no network is required.
#
# (2) We actually start the nickserver on 127.0.0.1 and talk to it via http.
#
# (3) the "Host" header for requests to nickserver must be set (or Config.domain set)
#

class NickserverTest < Minitest::Test
  include HttpStubHelper

  def setup
    super
    Celluloid.boot
  end

  def teardown
    Celluloid.shutdown
    super
  end

  def test_GET_key_by_email_address_served_via_SKS
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'
    stub_nicknym_available_response 'leap.se', status: 404
    stub_sks_vindex_reponse(uid, body: file_content(:leap_vindex_result))
    stub_sks_get_reponse(key_id, body: file_content(:leap_public_key))

    start do
      params = {query: {"address" => uid}}
      get(params) do |response|
        assert_equal file_content(:leap_public_key), JSON.parse(response.to_s)["openpgp"]
      end
    end
  end

  def test_GET_key_by_fingerprint_served_via_SKS
    fingerprint = 'E818C478D3141282F7590D29D041EB11B1647490'
    stub_sks_get_reponse(fingerprint, body: file_content(:leap_public_key))

    start do
      params = {query: {"fingerprint" => fingerprint}}
      get(params) do |response|
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
    stubbing_http do
      yield server
    end
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
