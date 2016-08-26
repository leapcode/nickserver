require 'nickserver/hkp/source'
require 'nickserver/couch_db/source'

module Nickserver
  class RequestHandler

    class Request
      def initialize(params, headers)
        @params = params || {}
        @headers = headers
      end

      def email
        param("address")
      end

      def fingerprint
        param("fingerprint")
      end

      def domain
        host_header = headers['Host']
        raise MissingHostHeader if host_header.nil?
        host_header.split(':')[0].strip.sub(/^nicknym\./, '')
      end

      protected

      def param(key)
        params[key] && params[key].first
      end

      attr_reader :params, :headers
    end

    def initialize(responder, adapter)
      @responder = responder
      @adapter = adapter
    end

    def respond_to(params, headers)
      request = Request.new params, headers
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
        EmailHandler.new adapter
      elsif request.fingerprint
        FingerprintHandler.new adapter
      else
        Proc.new { Nickserver::Response.new(404, "Not Found\n") }
      end
    end

    class EmailHandler

      def initialize(adapter)
        @adapter = adapter
      end

      def call(request)
        email = EmailAddress.new(request.email)
        if email.invalid?
          ErrorResponse.new("Not a valid address")
        else
          send_key(email, request)
        end
      end

      protected

      def send_key(email, request)
        if local_address?(email, request)
          source = Nickserver::CouchDB::Source.new(adapter)
        else
          source = Nickserver::Hkp::Source.new(adapter)
        end
        source.query(email)
      rescue MissingHostHeader
        ErrorResponse.new("HTTP request must include a Host header.")
      end

      #
      # Return true if the user address is for a user of this service provider.
      # e.g. if the provider is example.org, then alice@example.org returns true.
      #
      # If 'domain' is not configured, we rely on the Host header of the HTTP request.
      #
      def local_address?(email, request)
        email.domain?(Config.domain || request.domain)
      end

      attr_reader :adapter
    end

    class FingerprintHandler

      def initialize(adapter)
        @adapter = adapter
      end

      def call(request)
        fingerprint = request.fingerprint
        if fingerprint.length == 40 && !fingerprint[/\H/]
          source = Nickserver::Hkp::Source.new(adapter)
          source.get_key_by_fingerprint(fingerprint)
        else
          ErrorResponse.new('Fingerprint invalid: ' + fingerprint)
        end
      end

      protected

      attr_reader :adapter
    end

    class ErrorResponse < Nickserver::Response
      def initialize(message)
        @status = 500
        @message = message + "\n"
      end
    end

    def send_response(status = 200, content = '')
      responder.respond status, content
    end

    attr_reader :responder, :adapter

    class MissingHostHeader < StandardError
    end
  end
end
