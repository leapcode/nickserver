module Nickserver
  class Source

    def initialize(adapter)
      @adapter = adapter
    end

    protected

    attr_reader :adapter

  end
end
