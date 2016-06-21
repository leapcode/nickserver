require 'kernel_ext'
require 'json'
require 'nickserver/em_server'
require 'nickserver/couch_db/source'
require 'nickserver/hkp/source'
require 'nickserver/adapters/em_http'


#
# This is the main HTTP server that clients connect to in order to fetch keys
#
# For info on EM::HttpServer, see https://github.com/eventmachine/evma_httpserver
#
module Nickserver
  class Server

    #
    # Starts the Nickserver. Must be run inside an EM.run block.
    #
    # Available options:
    #
    #   * :port (default Nickserver::Config.port)
    #   * :host (default 127.0.0.1)
    #
    def self.start(opts={})
      Nickserver::Config.load
      options = {
        host: '127.0.0.1',
        port: Nickserver::Config.port.to_i
      }.merge(opts)

      unless defined?(TESTING)
        puts "Starting nickserver #{options[:host]}:#{options[:port]}"
      end

      Nickserver::EmServer.start(options)
    end


  end
end
