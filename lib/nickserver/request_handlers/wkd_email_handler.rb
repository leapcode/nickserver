require 'nickserver/email_address'
require 'nickserver/wkd/source'

module Nickserver
  module RequestHandlers
    class WkdEmailHandler < Base
      def handle
        source.query(email) if request.email
      end

      protected

      def email
        @email ||= EmailAddress.new(request.email)
      end

      def source
        Nickserver::Wkd::Source.new adapter
      end
    end
  end
end
