require 'nickserver/email_address'
require 'nickserver/hkp/source'

module Nickserver
  module RequestHandlers
    class HkpEmailHandler < Base
      def handle
        source.query(email) if request.email
      end

      protected

      def email
        @email ||= EmailAddress.new(request.email)
      end

      def source
        Nickserver::Hkp::Source.new adapter
      end
    end
  end
end
