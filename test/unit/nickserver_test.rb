require File.expand_path('test_helper', File.dirname(__FILE__))
require 'json'

#
# Some important notes to understanding these tests:
#
# (1) Requests to localhost always bypass HTTP stub.
#
# (2) All requests to nickserver are to localhost.
#
# (3) the "Host" header for requests to nickserver must be set (or Config.domain set)
#
# (4) When stubbing requests to couchdb, the couchdb host is changed from the
# default (localhost) to a dummy value (notlocalhost).
#

class NickserverTest < Minitest::Test

  def test_GET_served_via_SKS
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'
    stub_sks_vindex_reponse(uid, :body => file_content(:leap_vindex_result))
    stub_sks_get_reponse(key_id, :body => file_content(:leap_public_key))

    start do
      params = {:query => {"address" => uid}}
      get(params) do |http|
        assert_equal file_content(:leap_public_key), JSON.parse(http.response)["openpgp"]
        stop
      end
    end
  end

  def test_POST_served_via_SKS
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'
    stub_sks_vindex_reponse(uid, :body => file_content(:leap_vindex_result))
    stub_sks_get_reponse(key_id, :body => file_content(:leap_public_key))

    start do
      params = {:body => {"address" => uid}}
      post(params) do |http|
        assert_equal file_content(:leap_public_key), JSON.parse(http.response)["openpgp"]
        stop
      end
    end
  end

  def test_GET_served_via_couch_not_found
    domain = "example.org"
    uid    = "bananas@" + domain
    stub_couch_response(uid, :status => 404) do
      start do
        params = {:query => {"address" => uid}, :head => {:host => domain}}
        get(params) do |http|
          assert_equal 404, http.response_header.status
          stop
        end
      end
    end
  end

  def test_GET_served_via_couch_empty_results
    domain = "example.org"
    uid    = "stompy@" + domain
    stub_couch_response(uid, :body => file_content(:empty_couchdb_result)) do
      start do
        params = {:query => {"address" => uid}, :head => {:host => domain}}
        get(params) do |http|
          assert_equal 404, http.response_header.status
          stop
        end
      end
    end
  end

  def test_GET_served_via_couch_success
    domain = "example.org"
    uid    = "blue@" + domain
    stub_couch_response(uid, :body => file_content(:blue_couchdb_result)) do
      start do
        params = {:query => {"address" => uid}, :head => {:host => domain}}
        get(params) do |http|
          assert_equal file_content(:blue_nickserver_result), http.response
          stop
        end
      end
    end
  end

  def test_GET_empty
    start do
      get({}) do |http|
        assert_equal "404 Not Found\n", http.response
        stop
      end
    end
  end

  protected

  #
  # start nickserver
  #
  def start(timeout = 1)
    Timeout::timeout(timeout) do
      EM.run do
        Nickserver::Server.start
        EM.epoll
        yield
      end
    end
  rescue Timeout::Error
    flunk 'EventMachine was not stopped before the timeout expired'
  end

  #
  # http GET requests to nickserver
  #
  def get(params, &block)
    request(:get, params, &block)
  end

  #
  # http POST requests to nickserver
  #
  def post(params, &block)
    request(:post, params, &block)
  end

  #
  # http request to nickserver
  #
  # this works because http requests to localhost are not stubbed, but requests to other domains are.
  #
  def request(method, params)
    EventMachine::HttpRequest.new("http://localhost:#{Nickserver::Config.port}/").send(method,params).callback {|http|
      # p http.response_header.status
      # p http.response_header
      # p http.response
      yield http
    }.errback {|http|
      flunk(http.error) if http.error
      EM.stop
    }
  end

  #
  # stop nickserver
  #
  def stop
    EM.stop
  end

end
