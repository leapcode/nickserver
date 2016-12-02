require 'nickserver/source'
require 'nickserver/response'

module Nickserver
  module Nicknym
    class Source < Nickserver::Source
      # port we expect the remote nicknym to listen on
      PORT = 6425

      def available_for?(domain)
        status, body = adapter.get "https://#{domain}/provider.json"
        status == 200 && provider_with_mx?(body)
      end

      def query(email)
        status, body = nicknym_get email.domain, address: email.to_s
        return Nickserver::Response.new(status, body)
      end

      protected

      def nicknym_get(domain, query = {})
        url = "https://nicknym.#{domain}:#{PORT}"
        adapter.get(url, query: query)
      end

      def provider_with_mx?(provider_json)
        provider = JSON.parse provider_json
        services = provider['services'] || []
        services.include?('mx')
      rescue JSON::ParserError
        return false
      end
    end
  end
end
