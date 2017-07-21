require 'nickserver/request_handlers/base'
require 'nickserver/email_address'
require 'nickserver/couch_db/source'

module Nickserver
  module RequestHandlers
    class LocalEmailHandler < Base

      def handle
        source.query(email) if request.email && email.domain?(domain)
      end

      protected

      def domain
        Config.domain || request.domain
      end

      def email
        @email ||= EmailAddress.new(request.email)
      end

      def source
        Nickserver::CouchDB::Source.new adapter
      end

    end
  end
end
