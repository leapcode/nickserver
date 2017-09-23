require 'kernel_ext'
require 'json'

require 'nickserver/config'
require 'nickserver/reel_server'

#
# This is the main HTTP server that clients connect to in order to fetch keys
#
#
module Nickserver
  class Server
    #
    # Starts the Nickserver.
    #
    # Available options:
    #
    #   * :port (default Nickserver::Config.port)
    #   * :host (default 127.0.0.1)
    #
    def self.start(opts = {})
      Nickserver::Config.load
      options = {
        host: '127.0.0.1',
        port: Nickserver::Config.port.to_i
      }.merge(opts)

      unless defined?(TESTING)
        puts "Starting nickserver #{options[:host]}:#{options[:port]}"
      end

      Nickserver::ReelServer.start(options)
    end
  end
end
