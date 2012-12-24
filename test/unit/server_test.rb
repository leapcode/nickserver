require File.expand_path('test_helper', File.dirname(__FILE__))

class ServerTest < MiniTest::Unit::TestCase

  def test_server
    uid    = 'cloudadmin@leap.se'
    key_id = 'E818C478D3141282F7590D29D041EB11B1647490'
    stub_vindex_response(uid, :body => file_content(:leap_vindex_result))
    stub_get_response(key_id, :body => file_content(:leap_public_key))

    EM.run do
      EM.start_server '0.0.0.0', Nickserver::Config.port, Nickserver::Server

      params = {:query => {}, :path => "key/#{CGI.escape(uid)}"}
      http = EventMachine::HttpRequest.new("http://localhost:#{Nickserver::Config.port}").get(params)
      http.callback {
        assert_equal file_content(:leap_public_key), http.response
        EM.stop
      }.errback {
        puts http.error
        EM.stop
      }

      #socket = EM.connect('0.0.0.0', Nickserver::Config.port, TestSocketClient)
      #socket.onopen = lambda {
      #  server.players.size.should == 1
      #  socket.data.last.chomp.should == "READY"
      #  EM.stop
      #}
    end
  end

end

