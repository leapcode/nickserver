require 'nickserver/email_address'
require 'nickserver/hkp/source'

module Nickserver
  module RequestHandlers
    class EmailHandler

      def call(request)
        return unless request.email
        email = EmailAddress.new(request.email)
        source.query(email)
      end

      protected

      def source
        Nickserver::Hkp::Source.new
      end

    end
  end
end
