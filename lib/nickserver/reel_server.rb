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

    DEFAULT_ADAPTER_CLASS = Nickserver::Adapters::CelluloidHttp

    def self.start(options = {})
      new(options[:host], options[:port])
    end

    def initialize(host = "127.0.0.1", port = 3000)
      Celluloid.logger = logger
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
      logging_request(request) do
        with_http_adapter do |adapter|
          handler = handler_for(request, adapter)
          handler.respond_to params(request), request.headers
        end
      end
    rescue StandardError => e
      request.respond 500, "{}"
    end

    def logging_request(request)
      logger.info "#{request.method} #{request.uri}"
      logger.debug "  #{params(request)}"
      yield
    rescue StandardError => e
      logger.error e
      logger.error e.backtrace.join "\n  "
      raise
    end

    def with_http_adapter
      adapter = DEFAULT_ADAPTER_CLASS.new
      yield adapter
    ensure
      adapter.terminate if adapter.respond_to? :terminate
    end

    def handler_for(request, adapter)
      # with reel the request is the responder
      responder = LoggingResponder.new(request, logger)
      Dispatcher.new(responder, adapter)
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
