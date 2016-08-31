require 'nickserver/adapters'
require 'nickserver/config'
silence_warnings do
  require 'celluloid/io'
end
require 'http'

module Nickserver::Adapters
  class CelluloidHttp
    silence_warnings do
      include Celluloid::IO
    end

    def get(url, options = {})
      response = HTTP.get url,
        params: options[:query],
        ssl_context: ctx,
        ssl_socket_class: Celluloid::IO::SSLSocket
      return response.code, response.to_s
    end

    def ctx
      OpenSSL::SSL::SSLContext.new.tap do |ctx|
        ctx.ca_file = Nickserver::Config.hkp_ca_file
      end
    end
  end
end
