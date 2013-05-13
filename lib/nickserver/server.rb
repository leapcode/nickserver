require 'eventmachine'
require 'evma_httpserver'
require 'json'

#
# This is the main HTTP server that clients connect to in order to fetch keys
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
      options = {:host => '0.0.0.0', :port => Nickserver::Config.port}.merge(opts)
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
      else
        send_key(uid)
      end
    end

    private

    def send_error(msg = "not supported")
      send_response(:status => 500, :content => msg)
    end

    def send_not_found(msg = "not found")
      send_response(:status => 404, :content => msg)
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
      if params["address"] && params["address"].any?
        return params["address"].first
      end
    end

    def get_key_from_uid(uid)
      if local_address?(uid)
        send_not_found
      else
        Nickserver::HKP::FetchKey.new.get(uid).callback {|key|
          yield key
        }.errback {|status|
          send_response(:status => status, :content => 'could not fetch key')
        }
      end
    end

    def format_response(map)
      map.to_json
    end

    #
    # Return true if the user address is for a user of this service provider.
    # e.g. if the provider is example.org, then alice@example.org returns true.
    #
    # Currently, we rely on whatever hostname the client voluntarily specifies
    # in the headers of the http request.
    #
    def local_address?(uid)
      hostname = @http_headers.split(/\0/).grep(/^Host: /).first.split(':')[1].strip.sub(/^nicknym\./, '')
      return uid =~ /^.*@#{Regexp.escape(hostname)}$/
    #rescue
    #  false
    end
  end
end