require 'nickserver/adapters/celluloid_http'

module Nickserver
  class Source

    def initialize(adapter = Nickserver::Adapters::CelluloidHttp.new)
      @adapter = adapter
    end

    protected

    attr_reader :adapter
  end
end
