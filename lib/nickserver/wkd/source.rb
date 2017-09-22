require 'nickserver/source'
require 'nickserver/response'
require 'nickserver/wkd/url'
require 'nickserver/hkp/response'

module Nickserver
  module Wkd
    class Source < Nickserver::Source

      def query(email)
        url = Url.new(email)
        status, blob = adapter.get url
        Hkp::Response.new(email.to_s, armor_key(blob)) if status == 200
      end

      protected

      def armor_key(blob)
        header + encode(blob) + footer
      end

      def encode(blob)
        Base64.strict_encode64(blob).scan(/.{1,64}/).join "\n"
      end

      def header
        "-----BEGIN PGP PUBLIC KEY BLOCK-----\n\n"
      end

      def footer
        "\n-----END PGP PUBLIC KEY BLOCK-----\n"
      end
    end
  end
end
