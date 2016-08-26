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
      if request.email
        by_email(request)
      elsif request.fingerprint
        by_fingerprint(request)
      else
        send_not_found
      end

    rescue RuntimeError => exc
      puts "Error: #{exc}"
      puts exc.backtrace
      send_error(exc.to_s)
    end

    protected

    def by_email(request)
      email = EmailAddress.new(request.email)
      if email.invalid?
        send_error("Not a valid address")
      else
        send_key(email, request)
      end
    end

    def by_fingerprint(request)
      fingerprint = request.fingerprint
      if fingerprint.length == 40 && !fingerprint[/\H/]
        source = Nickserver::Hkp::Source.new(adapter)
        key_response = source.get_key_by_fingerprint(fingerprint)
        send_response key_response.status, key_response.content
      else
        send_error('Fingerprint invalid: ' + fingerprint)
      end
    end

    def send_key(email, request)
      if local_address?(email, request)
        source = Nickserver::CouchDB::Source.new(adapter)
      else
        source = Nickserver::Hkp::Source.new(adapter)
      end
      response = source.query(email)
      send_response response.status, response.content
    rescue MissingHostHeader
      send_error("HTTP request must include a Host header.")
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

    def send_error(msg = "not supported")
      send_response 500, "500 #{msg}\n"
    end

    def send_not_found(msg = "Not Found")
      send_response 404, "404 #{msg}\n"
    end

    def send_response(status = 200, content = '')
      responder.respond status, content
    end

    attr_reader :responder, :adapter

    class MissingHostHeader < StandardError
    end
  end
end
