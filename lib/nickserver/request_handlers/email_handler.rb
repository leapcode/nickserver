require 'nickserver/email_address'
require 'nickserver/error_response'
require 'nickserver/hkp/source'
require 'nickserver/couch_db/source'

module Nickserver
  module RequestHandlers
    class EmailHandler

      def call(request)
        return unless request.email
        handle_request(request)
      end

      protected

      def handle_request(request)
        email = EmailAddress.new(request.email)
        if email.invalid?
          ErrorResponse.new("Not a valid address")
        else
          send_key(email, request)
        end
      end

      def send_key(email, request)
        if local_address?(email, request)
          source = Nickserver::CouchDB::Source.new
        else
          source = Nickserver::Hkp::Source.new
        end
        source.query(email)
      rescue MissingHostHeader
        ErrorResponse.new("HTTP request must include a Host header.")
      end

      #
      # Return true if the user address is for a user of this service provider.
      # e.g. if the provider is example.org, then alice@example.org returns true.
      #
      # If 'domain' is not configured, we rely on the Host header of the HTTP request.
      #
      def local_address?(email, request)
        domain = Config.domain || request.domain
        raise MissingHostHeader if domain == ''
        email.domain? domain
      end
    end


    class MissingHostHeader < StandardError
    end
  end
end
