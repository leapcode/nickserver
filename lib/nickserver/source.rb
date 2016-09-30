require 'nickserver/adapters/celluloid_http'

module Nickserver
  class Source

    DEFAULT_ADAPTER_CLASS = Nickserver::Adapters::CelluloidHttp

    def initialize(adapter = DEFAULT_ADAPTER_CLASS.new)
      @adapter = adapter
    end

    protected

    attr_reader :adapter
  end
end
