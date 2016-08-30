module Nickserver
  module RequestHandlers
    class Base

      def self.call(request)
        new(request).handle
      end

      def initialize(request)
        @request = request
      end

      protected
      attr_reader :request
    end
  end
end

