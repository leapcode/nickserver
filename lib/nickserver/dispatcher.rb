#
# Dispatcher
#
# Dispatch a request so it get's handled by the correct handler.
#
# The dispatcher hands a request to one handler after the other until one of
# them responds.
#
# This is similar to the Chain of Responsibility patter but we iterate over the
# 'handler_chain' array instead of a linked list.
#
# To change the order of handlers or add other handlers change the array in the
# handler_chain function.
#

require 'nickserver/request'
require 'nickserver/request_handlers/invalid_email_handler'
require 'nickserver/request_handlers/local_email_handler'
require 'nickserver/request_handlers/email_handler'
require 'nickserver/request_handlers/fingerprint_handler'

module Nickserver
  class Dispatcher

    def initialize(responder)
      @responder = responder
    end

    def respond_to(params, headers)
      request = Nickserver::Request.new params, headers
      response = handle request
      send_response response.status, response.content
    end

    protected

    def handle(request)
      handler_chain.each do |handler|
        response = handler.call request
        return response if response
      end
    rescue RuntimeError => exc
      puts "Error: #{exc}"
      puts exc.backtrace
      ErrorResponse.new(exc.to_s)
    end

    def handler_chain
      [
        RequestHandlers::InvalidEmailHandler.new,
        RequestHandlers::LocalEmailHandler.new,
        RequestHandlers::EmailHandler.new,
        RequestHandlers::FingerprintHandler.new,
        Proc.new { Nickserver::Response.new(404, "Not Found\n") }
      ]
    end

    def send_response(status = 200, content = '')
      responder.respond status, content
    end

    attr_reader :responder

  end
end
