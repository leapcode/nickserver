require 'eventmachine'
require 'evma_httpserver'
require 'json'

#
# This is the main HTTP server that clients connect to in order to fetch keys
#
# For info on EM::HttpServer, see https://github.com/eventmachine/evma_httpserver
#
module Nickserver
  class Server < EM::Connection
    include EM::HttpServer

    #
    # Starts the Nickserver. Must be run inside an EM.run block.
    #
    # Available options:
    #
    #   * :port (default Nickserver::Config.port)
    #   * :host (default 0.0.0.0)
    #
    def self.start(opts={})
      Nickserver::Config.load
      options = {:host => '0.0.0.0', :port => Nickserver::Config.port.to_i}.merge(opts)
      EM.start_server options[:host], options[:port], Nickserver::Server
    end

    def post_init
      super
      no_environment_strings
    end

    def process_http_request
      uid = get_uid_from_request
      if uid.nil?
        send_not_found
      elsif uid !~ EmailAddress
        send_error("Not a valid address")
      else
        send_key(uid)
      end
    end

    private

    def send_error(msg = "not supported")
      send_response(:status => 500, :content => "500 #{msg}\n")
    end

    def send_not_found(msg = "Not Found")
      send_response(:status => 404, :content => "404 #{msg}\n")
    end

    def send_response(opts = {})
      options = {:status => 200, :content_type => 'text/plain', :content => ''}.merge(opts)
      response = EM::DelegatedHttpResponse.new(self)
      response.status = options[:status]
      response.content_type options[:content_type]
      response.content = options[:content]
      response.send_response
    end

    def send_key(uid)
      get_key_from_uid(uid) do |key|
        send_response :content => format_response(:address => uid, :openpgp => key)
      end
    end

    def get_uid_from_request
      if @http_query_string
        params = CGI.parse(@http_query_string)
      elsif @http_post_content
        params = CGI.parse(@http_post_content)
      end
      if params && params["address"] && params["address"].any?
        return params["address"].first
      else
        return nil
      end
    end

    def get_key_from_uid(uid)
      fetcher = if local_address?(uid)
        Nickserver::Couch::FetchKey.new
      else
        Nickserver::HKP::FetchKey.new
      end
      fetcher.get(uid).callback {|key|
        yield key
      }.errback {|status, msg|
        if status == 404
          send_not_found
        else
          send_response(:status => status, :content => msg)
        end
      }
    end

    def format_response(map)
      map.to_json
    end

    #
    # Return true if the user address is for a user of this service provider.
    # e.g. if the provider is example.org, then alice@example.org returns true.
    #
    # If 'domain' is not configured, we rely on the Host header of the HTTP request.
    #
    def local_address?(uid)
      uid_domain = uid.sub(/^.*@(.*)$/, "\\1")
      if Config.domain
        return uid_domain == Config.domain
      else
        # no domain configured, use Host header
        host_header = @http_headers.split(/\0/).grep(/^Host: /).first
        if host_header.nil?
          send_error("HTTP request must include a Host header.")
        else
          host = host_header.split(':')[1].strip.sub(/^nicknym\./, '')
          return uid_domain == host
        end
      end
    rescue
      return false
    end
  end
end