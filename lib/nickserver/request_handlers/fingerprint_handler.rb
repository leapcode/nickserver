require 'nickserver/request_handlers/base'
require 'nickserver/hkp/source'
require 'nickserver/error_response'

module Nickserver
  module RequestHandlers
    class FingerprintHandler < Base

      def handle
        return unless fingerprint
        if fingerprint.length == 40 && !fingerprint[/\H/]
          source.get_key_by_fingerprint(fingerprint)
        else
          ErrorResponse.new('Fingerprint invalid: ' + fingerprint)
        end
      end

      protected

      def fingerprint
        request.fingerprint
      end

      def source
        Nickserver::Hkp::Source.new
      end

    end
  end
end
