require 'nickserver/adapters/http'
silence_warnings do
  require 'celluloid/io'
end

module Nickserver::Adapters
  # HTTP Adapter using Celluloid::IO
  class CelluloidHttp < Http
    silence_warnings do
      include Celluloid::IO
    end

    protected

    def default_options
      super.merge ssl_socket_class: Celluloid::IO::SSLSocket
    end
  end
end
