require 'eventmachine'
require 'evma_httpserver'


#
# This is the main HTTP server that clients connect to in order to fetch keys
#
module Nickserver
  class Server < EM::Connection
    include EM::HttpServer

    def post_init
      super
      no_environment_strings
    end

    def process_http_request
      # the http request details are available via the following instance variables:
      #   @http_protocol
      #   @http_request_method
      #   @http_cookie
      #   @http_if_none_match
      #   @http_content_type
      #   @http_path_info
      #   @http_request_uri
      #   @http_query_string
      #   @http_post_content
      #   @http_headers
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

    def send_key
      uid = CGI.unescape @http_path_info.sub(/^\/key\/(.*)/, '\1')
      get_key_from_uid(uid) do |key|
        send_response(:content => key)
      end
    end

    def send_response(opts = {})
      options = {:status => 200, :content_type => 'text/plain', :content => ''}.merge(opts)
      response = EM::DelegatedHttpResponse.new(self)
      response.status = options[:status]
      response.content_type options[:content_type]
      response.content = options[:content]
      response.send_response
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