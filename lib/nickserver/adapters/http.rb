require 'nickserver/adapters'
require 'nickserver/config'
require 'http'

module Nickserver::Adapters
  class Http

    def get(url, options = {})
      response = HTTP.get url,
        params: options[:query],
        ssl_context: ctx
      return response.code, response.to_s
    end

    def ctx
      OpenSSL::SSL::SSLContext.new.tap do |ctx|
        ctx.ca_file = Nickserver::Config.hkp_ca_file
      end
    end
  end
end
