require File.expand_path('test_helper', File.dirname(__FILE__))

class ServerTest < MiniTest::Unit::TestCase

  #
  # this test works because http requests to localhost are not stubbed, but requests to other domains are.
  #
  def test_server
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'
    stub_vindex_response(uid, :body => file_content(:leap_vindex_result))
    stub_get_response(key_id, :body => file_content(:leap_public_key))

    EM.run do
      Nickserver::Server.start
      params = {:query => {}, :path => "key/#{CGI.escape(uid)}"}
      http = EventMachine::HttpRequest.new("http://localhost:#{Nickserver::Config.port}").get(params)
      http.callback {
        assert_equal file_content(:leap_public_key), http.response
        EM.stop
        return
      }.errback {
        flunk http.error
        EM.stop
      }
    end
    flunk 'should not get here'
  end

end
