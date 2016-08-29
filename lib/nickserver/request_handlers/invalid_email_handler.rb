require 'nickserver/email_address'
require 'nickserver/error_response'

module Nickserver
  module RequestHandlers
    class InvalidEmailHandler
      def call(request)
        return unless request.email
        email = EmailAddress.new(request.email)
        ErrorResponse.new("Not a valid address") if email.invalid?
      end

    end
  end
end
