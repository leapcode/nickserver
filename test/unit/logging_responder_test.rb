require 'test_helper'
require 'nickserver/logging_responder'

module Nickserver
  class LoggingResponderTest < Minitest::Test
    def test_responds_and_logs
      logger.expect :info, nil, [' -> 200']
      respond_to 200, 'body'
      logger.verify
    end

    protected

    def respond_to(*args)
      responder.expect :respond, nil, args
      logging_responder = LoggingResponder.new responder, logger
      logging_responder.respond(*args)
      responder.verify
    end

    def responder
      @responder ||= Minitest::Mock.new
    end

    def logger
      @logger ||= Minitest::Mock.new
    end
  end
end
