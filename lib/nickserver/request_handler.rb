module Nickserver
  class RequestHandler

    def initialize(responder, adapter)
      @responder = responder
      @adapter = adapter
    end

    def respond_to(params, headers)
      uid = get_uid_from_params(params)
      if uid.nil?
        send_not_found
      elsif uid !~ EmailAddress
        send_error("Not a valid address")
      else
        send_key(uid, headers)
      end
    rescue RuntimeError => exc
      puts "Error: #{exc}"
      puts exc.backtrace
      send_error(exc.to_s)
    end

    protected

    def get_uid_from_params(params)
      if params && params["address"] && params["address"].any?
        return params["address"].first
      else
        return nil
      end
    end

    def send_key(uid, headers)
      if local_address?(uid, headers)
        source = Nickserver::CouchDB::Source.new(adapter)
      else
        source = Nickserver::Hkp::Source.new(adapter)
      end
      source.query(uid) do |response|
        send_response(status: response.status, content: response.content)
      end
    end

    #
    # Return true if the user address is for a user of this service provider.
    # e.g. if the provider is example.org, then alice@example.org returns true.
    #
    # If 'domain' is not configured, we rely on the Host header of the HTTP request.
    #
    def local_address?(uid, headers)
      uid_domain = uid.sub(/^.*@(.*)$/, "\\1")
      if Config.domain
        return uid_domain == Config.domain
      else
        # no domain configured, use Host header
        host_header = headers.split(/\0/).grep(/^Host: /).first
        if host_header.nil?
          send_error("HTTP request must include a Host header.")
        else
          host = host_header.split(':')[1].strip.sub(/^nicknym\./, '')
          return uid_domain == host
        end
      end
    end
    def send_error(msg = "not supported")
      send_response(status: 500, content: "500 #{msg}\n")
    end

    def send_not_found(msg = "Not Found")
      send_response(status: 404, content: "404 #{msg}\n")
    end

    def send_response(opts = {})
      responder.send_response default_response.merge(opts)
    end

    def default_response
      {status: 200, content_type: 'text/plain', content: ''}
    end

    attr_reader :responder, :adapter

  end
end
