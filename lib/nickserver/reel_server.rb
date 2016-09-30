silence_warnings do
  require 'reel'
end
require 'logger'
require 'nickserver/config'
require 'nickserver/adapters/celluloid_http'
require 'nickserver/dispatcher'
require 'nickserver/logging_responder'

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
        handle_request(request)
      end
    end


    protected

    def handle_request(request)
      logger.info "#{request.method} #{request.uri}"
      logger.debug "  #{params(request)}"
      handler = handler_for(request)
      handler.respond_to params(request), request.headers
    rescue StandardError => e
      logger.error e
      logger.error e.backtrace.join "\n  "
      request.respond 500, "{}"
    end

    def handler_for(request)
      # with reel the request is the responder
      responder = LoggingResponder.new(request, logger)
      Dispatcher.new(responder)
    end

    def params(request)
      if request.query_string
        CGI.parse request.query_string
      else
        CGI.parse request.body.to_s
      end
    end

    def logger
      @logger ||= ::Logger.new Config.log_file
    end
  end
end
