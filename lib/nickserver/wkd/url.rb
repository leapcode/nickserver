require 'digest/sha1'
require 'zbase32'

module Nickserver
  module Wkd
    class Url

      def initialize(email)
        @domain = email.domain.downcase
        @local_part = email.local_part.downcase
      end

      def to_s
        "https://#{domain}/.well-known/openpgpkey" +
          "/hu/#{domain}/#{encoded_digest}"
      end

      protected

      attr_reader :domain, :local_part

      def encoded_digest
        ZBase32.encode32(digest.to_i(16).to_s(2))
      end

      def digest
        Digest::SHA1.hexdigest local_part
      end
    end
  end
end
