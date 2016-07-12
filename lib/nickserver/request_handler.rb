require 'nickserver/hkp/source'
require 'nickserver/couch_db/source'

module Nickserver
  class RequestHandler

    def initialize(responder, adapter)
      @responder = responder
      @adapter = adapter
    end

    def respond_to(params, headers)
      if params && params["address"] && params["address"].any?
        by_email(params, headers)
      elsif params && params["fingerprint"] && params["fingerprint"].any?
        # do something else
      else
        send_not_found
      end

    rescue RuntimeError => exc
      puts "Error: #{exc}"
      puts exc.backtrace
      send_error(exc.to_s)
    end

    protected

    def by_email(params, headers)
      email = EmailAddress.new(params["address"].first)
      if email.invalid?
        send_error("Not a valid address")
      else
        send_key(email, headers)
      end
    end

    #def by_fingerprint(params)

    def send_key(email, headers)
      if local_address?(email, headers)
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
    def local_address?(email, headers)
      email.domain?(Config.domain || domain_from_headers(headers))
    end

    # no domain configured, use Host header
    def domain_from_headers(headers)
      host_header = headers['Host']
      raise MissingHostHeader if host_header.nil?
      host_header.split(':')[0].strip.sub(/^nicknym\./, '')
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
