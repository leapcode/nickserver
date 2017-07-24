require 'nickserver/adapters'
require 'nickserver/config'
require 'http'

# Nickserver::Adapters::Http
#
# Basic http adapter with ssl and minimal error handling.
# Only implemented get requests so far.
#
# Error Handling:
#
# Pass a string as the 'rescue' option. If a ConnectionError occures
# which includes the string passed it will be rescued and the request
# will return nil. This allows handling the error inside the adapter so
# that for the derived CelluloidHttp Adapter the actor does not get
# killed.

module Nickserver::Adapters
  class Http

    def get(url, options = {})
      url = HTTP::URI.parse url.to_s
      response = get_with_auth url, params: options[:query]
      return response.code, response.to_s
    rescue HTTP::ConnectionError => e
      raise unless options[:rescue] && e.to_s.include?(options[:rescue])
    end

    protected

    def get_with_auth(url, options)
      options = default_options.merge options
      http_with_basic_auth(url).get url, options
    end

    def http_with_basic_auth(url)
      if url.password && (url.password != '')
        HTTP.basic_auth(user: url.user, pass: url.password)
      else
        HTTP
      end
    end

    def default_options
      { ssl_context: ctx }
    end

    def ctx
      OpenSSL::SSL::SSLContext.new.tap do |ctx|
        ctx.ca_file = Nickserver::Config.hkp_ca_file
      end
    end
  end
end
