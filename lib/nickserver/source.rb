require 'nickserver/adapters/http'

module Nickserver
  class Source

    def initialize(adapter = Nickserver::Adapters::Http.new)
      @adapter = adapter
    end

    protected

    attr_reader :adapter
  end
end
