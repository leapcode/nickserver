module Nickserver
  class Source
    def initialize(adapter = nil)
      @adapter = adapter
    end

    protected

    attr_reader :adapter
  end
end
