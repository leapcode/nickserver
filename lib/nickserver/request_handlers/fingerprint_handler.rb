require 'nickserver/hkp/source'
require 'nickserver/error_response'

module Nickserver
  module RequestHandlers
    class FingerprintHandler

      def call(request)
        return unless request.fingerprint
        handle_request(request)
      end

      protected

      def handle_request(request)
        fingerprint = request.fingerprint
        if fingerprint.length == 40 && !fingerprint[/\H/]
          source = Nickserver::Hkp::Source.new
          source.get_key_by_fingerprint(fingerprint)
        else
          ErrorResponse.new('Fingerprint invalid: ' + fingerprint)
        end
      end

    end
  end
end
