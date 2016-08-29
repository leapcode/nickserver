require 'nickserver/request'
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
      handler = handler_for_request request
      handler.call request
    rescue RuntimeError => exc
      puts "Error: #{exc}"
      puts exc.backtrace
      ErrorResponse.new(exc.to_s)
    end

    def handler_for_request(request)
      if request.email
        RequestHandlers::EmailHandler.new
      elsif request.fingerprint
        RequestHandlers::FingerprintHandler.new
      else
        Proc.new { Nickserver::Response.new(404, "Not Found\n") }
      end
    end

    def send_response(status = 200, content = '')
      responder.respond status, content
    end

    attr_reader :responder

  end
end
