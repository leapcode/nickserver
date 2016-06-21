require 'eventmachine'
silence_warnings do
  require 'evma_httpserver'
end
require 'nickserver/request_handler'

module Nickserver
  class EmServer < EM::Connection
    include EM::HttpServer

    def self.start(options = {})
      EventMachine.run do
        EM.start_server options[:host], options[:port], self
      end
    end

    def post_init
      super
      no_environment_strings
    end

    def process_http_request
      handler.respond_to params, @http_headers
    end

    def send_response(options = {})
      response = EM::DelegatedHttpResponse.new(self)
      response.status = options[:status]
      response.content_type options[:content_type]
      response.content = options[:content]
      silence_warnings do
        response.send_response
      end
    end

    private

    def handler
      @handler ||= RequestHandler.new(self, Nickserver::Adapters::EmHttp.new)
    end

    def params
      if @http_query_string
        CGI.parse(@http_query_string)
      elsif @http_post_content
        CGI.parse(@http_post_content)
      end
    end

  end
end
