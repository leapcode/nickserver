module Nickserver
  module RequestHandlers
    class Base

      def self.call(request, adapter = nil)
        new(request, adapter).handle
      end

      def initialize(request, adapter)
        @request = request
        @adapter = adapter
      end

      protected
      attr_reader :request, :adapter
    end
  end
end

