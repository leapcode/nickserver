module Nickserver
  class LoggingResponder

    def initialize(responder, logger)
      @responder = responder
      @logger = logger
    end

    def respond(status, body)
      logger.info " -> #{status}"
      responder.respond(status, body)
    end

    protected

    attr_reader :responder, :logger
  end
end
