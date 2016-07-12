silence_warnings do
  require 'reel'
end
require 'nickserver/adapters/celluloid_http'
require 'nickserver/request_handler'

module Nickserver
  class ReelServer < Reel::Server::HTTP

    def self.start(options = {})
      new(options[:host], options[:port])
    end

    def initialize(host = "127.0.0.1", port = 3000)
      super(host, port, &method(:on_connection))
    end

    def handle_connection(*args)
      silence_warnings do
        super
      end
    end

    def on_connection(connection)
      connection.each_request do |request|
        handler = handler_for(request)
        handler.respond_to params(request), request.headers
      end
    end


    protected

    def handler_for(request)
      RequestHandler.new(request, Nickserver::Adapters::CelluloidHttp.new)
    end

    def params(request)
      if request.query_string
        CGI.parse request.query_string
      else
        CGI.parse request.body.to_s
      end
    end

  end
end
