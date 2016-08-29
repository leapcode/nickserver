require 'nickserver/email_address'
require 'nickserver/error_response'
require 'nickserver/couch_db/source'

module Nickserver
  module RequestHandlers
    class LocalEmailHandler

      def call(request)
        return nil unless request.email
        domain = Config.domain || request.domain
        return missing_domain_response if domain.nil? || domain == ''
        email = EmailAddress.new(request.email)
        return nil unless email.domain?(domain)
        source.query email
      end

      protected

      attr_reader :domain

      def source
        Nickserver::CouchDB::Source.new
      end

      def missing_domain_response
        ErrorResponse.new "HTTP request must include a Host header."
      end

    end
  end
end
