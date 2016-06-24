require 'nickserver/adapters'
# require 'celluloid/io'
require 'http'

module Nickserver::Adapters
  class CelluloidHttp
  #  include Celluloid::IO

    def get(url, options = {})
      response = HTTP.get url,
        params: options[:query]
  #      ssl_socket_class: Celluloid::IO::SSLSocket
      yield response.code, response.to_s
    end

  end
end
