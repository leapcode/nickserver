require 'nickserver/request_handlers/base'
require 'nickserver/email_address'
require 'nickserver/error_response'

module Nickserver
  module RequestHandlers
    class InvalidEmailHandler < Base
      def handle
        return unless request.email
        ErrorResponse.new('Not a valid address') if email.invalid?
      end

      protected

      def email
        @email ||= EmailAddress.new(request.email)
      end
    end
  end
end
