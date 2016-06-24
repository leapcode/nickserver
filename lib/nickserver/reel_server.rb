require 'celluloid/autostart'
require 'reel'
require 'nickserver/adapters/celluloid_http'
require 'nickserver/request_handler'

module Nickserver
  class ReelServer

    def self.start(options = {})
      Reel::Server::HTTP.run(options[:host], options[:port]) do |connection|
        # Support multiple keep-alive requests per connection
        connection.each_request do |request|
          handler = handler_for(request)
          handler.respond_to params(request), request.headers
        end
      end
    end

    protected

    def self.handler_for(request)
      RequestHandler.new(request, Nickserver::Adapters::CelluloidHttp.new)
    end

    def self.params(request)
      if request.query_string
        CGI.parse request.query_string
      else
        CGI.parse request.body.to_s
      end
    end

  end
end
