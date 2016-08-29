require 'nickserver/email_address'
require 'nickserver/error_response'
require 'nickserver/couch_db/source'

module Nickserver
  module RequestHandlers
    class LocalEmailHandler

      def call(request)
        return nil unless request.email
        domain = Config.domain || request.domain
        email = EmailAddress.new(request.email)
        return nil unless email.domain?(domain)
        source.query email
      end

      protected

      def source
        Nickserver::CouchDB::Source.new
      end

    end
  end
end
