require 'nickserver/request_handlers/base'
require 'nickserver/email_address'
require 'nickserver/nicknym/source'

module Nickserver
  module RequestHandlers
    class LeapEmailHandler < Base

      def handle
        source.query(email) if request.email && remote_email? && nicknym_email?
      end

      protected

      def source
        @source ||= Nicknym::Source.new adapter
      end

      def remote_email?
        !email.domain?(domain)
      end

      def nicknym_email?
        source.available_for?(email.domain)
      end

      def email
        @email ||= EmailAddress.new(request.email)
      end

      def domain
        Config.domain || request.domain
      end

    end
  end
end
