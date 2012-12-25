require 'eventmachine'
require 'evma_httpserver'

#
# This is the main HTTP server that clients connect to in order to fetch keys
#
# For now, its API is very simple:
#
#   GET /keys/<uid>   --> returns OpenPGP key for uid.
#
module Nickserver
  class Server < EM::Connection
    include EM::HttpServer

    #
    # Starts the Nickserver. Must be run inside an EM.run block.
    #
    # Available options:
    #
    #   * :port (default Nickserver::Config.port)
    #   * :host (default 0.0.0.0)
    #
    def self.start(opts={})
      options = {:host => '0.0.0.0', :port => Nickserver::Config.port}.merge(opts)
      EM.start_server options[:host], options[:port], Nickserver::Server
    end

    def post_init
      super
      no_environment_strings
    end

    def process_http_request
      if @http_request_method == "GET"
        if @http_path_info =~ /^\/key\//
          send_key
        else
          send_error("malformed path: #{@http_path_info}")
        end
      else
        send_error("only GET is supported")
      end
    end

    private

    def send_error(msg = "not supported")
      send_response(:status => 500, :content => msg)
    end

    def send_response(opts = {})
      options = {:status => 200, :content_type => 'text/plain', :content => ''}.merge(opts)
      response = EM::DelegatedHttpResponse.new(self)
      response.status = options[:status]
      response.content_type options[:content_type]
      response.content = options[:content]
      response.send_response
    end

    def send_key
      uid = CGI.unescape @http_path_info.sub(/^\/key\/(.*)/, '\1')
      get_key_from_uid(uid) do |key|
        send_response(:content => key)
      end
    end

    def get_key_from_uid(uid)
      Nickserver::HKP::FetchKey.new.get(uid).callback {|key|
        yield key
      }.errback {|status|
        send_response(:status => status, :content => 'could not fetch key')
      }
    end
  end
end