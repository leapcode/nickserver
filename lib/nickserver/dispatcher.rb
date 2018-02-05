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

require 'http'

require 'nickserver/request'
require 'nickserver/handler_chain'
require 'nickserver/request_handlers/invalid_email_handler'
require 'nickserver/request_handlers/local_email_handler'
require 'nickserver/request_handlers/leap_email_handler'
require 'nickserver/request_handlers/wkd_email_handler'
require 'nickserver/request_handlers/hkp_email_handler'
require 'nickserver/request_handlers/fingerprint_handler'

module Nickserver
  class Dispatcher
    def initialize(responder, adapter = nil)
      @responder = responder
      @adapter = adapter
    end

    def respond_to(params, headers)
      request = Nickserver::Request.new params, headers
      response = handle request
      responder.respond response.status, response.content
    end

    protected

    attr_reader :responder, :adapter

    def handle(request)
      handler_chain.handle request, adapter
    end

    def handler_chain
      @handler_chain ||= init_handler_chain
    end

    def init_handler_chain
      chain = HandlerChain.new RequestHandlers::InvalidEmailHandler,
                               RequestHandlers::LocalEmailHandler,
                               RequestHandlers::LeapEmailHandler,
                               RequestHandlers::WkdEmailHandler,
                               RequestHandlers::HkpEmailHandler,
                               RequestHandlers::FingerprintHandler,
                               proc { proxy_error_response },
                               proc { Nickserver::Response.new(404, "404 Not Found\n") }
      chain.continue_on HTTP::ConnectionError
      chain
    end

    def proxy_error_response
      exc = handler_chain.rescued_exceptions.first
      if exc
        Nickserver::Response.new 502,
                                 JSON.dump(error: exc.to_s)
      end
    end
  end
end
