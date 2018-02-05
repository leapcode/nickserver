require 'test_helper'
require 'support/celluloid_test'
require 'support/http_stub_helper'
require 'nickserver/server'
require 'json'

# Integration Test for the whole nickserver without network dependecy.
#
# These tests are meant to test the integration between the different
# components of the nickserver from the ReelServer all the way down to
# the different sources.
# These tests do not test the low level network adapter, the daemonization
# or the startup script.
#
# Some important notes to understanding these tests:
#
# (1) We mock the http adapter. So no network is required.
#
# (2) We actually start the Reelserver on 127.0.0.1 and talk to it via http.
#     In order to run the Reelserver properly this is a celluloid test.
#
# (3) the "Host" header for requests to nickserver must be set
#     (or Config.domain set)
#

class NickserverTest < CelluloidTest
  include HttpStubHelper

  def test_key_by_email_address_from_sks
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'
    stub_nicknym_available_response 'leap.se', status: 404
    stub_wkd_response uid, status: 404
    stub_sks_vindex_reponse(uid, body: file_content(:leap_vindex_result))
    stub_sks_get_reponse(key_id, body: file_content(:leap_public_key))

    start do
      params = { query: { 'address' => uid } }
      assert_responds_to params, key: :leap_public_key
    end
  end

  def test_key_by_fingerprint_from_sks
    fingerprint = 'E818C478D3141282F7590D29D041EB11B1647490'
    stub_sks_get_reponse(fingerprint, body: file_content(:leap_public_key))

    start do
      params = { query: { 'fingerprint' => fingerprint } }
      assert_responds_to params, key: :leap_public_key
    end
  end

  def test_couch_user_not_found
    domain = 'example.org'
    uid    = 'bananas@' + domain
    stub_couch_response(uid, status: 404) do
      start do
        params = { query: { 'address' => uid }, head: { 'Host' => domain } }
        assert_responds_to params, code: 404
      end
    end
  end

  def test_couch_empty_results
    domain = 'example.org'
    uid    = 'stompy@' + domain
    stub_couch_response(uid, body: file_content(:empty_couchdb_result)) do
      start do
        params = { query: { 'address' => uid }, head: { host: domain } }
        assert_responds_to params, code: 404
      end
    end
  end

  def test_couch_success_response
    domain = 'example.org'
    uid    = 'blue@' + domain
    stub_couch_response(uid, body: file_content(:blue_couchdb_result)) do
      start do
        params = { query: { 'address' => uid }, head: { 'Host' => domain } }
        get(params) do |response|
          assert_equal file_content(:blue_nickserver_result), response.to_s
        end
      end
    end
  end

  def test_empty_get
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
  def start(_timeout = 1)
    server = Nickserver::ReelServer.new '127.0.0.1', config.port
    stubbing_http do
      yield server
    end
  ensure
    server.terminate if server && server.alive?
  end

  def assert_responds_to(params, key: nil, code: nil)
    get(params) do |response|
      assert_equal code, response.code if code
      if key
        assert_equal file_content(key),
                     JSON.parse(response.to_s)['openpgp']
      end
    end
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
  # this works because http requests to 127.0.0.1 are not stubbed, but
  # requests to other domains are.
  #
  def request(method, options = {})
    response = HTTP
               .headers(options.delete(:head))
               .request method, "http://127.0.0.1:#{config.port}/", options
    yield response
  end
end
