require 'nickserver/source'
require 'nickserver/response'

module Nickserver
  module Nicknym
    class Source < Nickserver::Source

      def available_for?(domain)
        status, _body = get "#{domain}/provider.json"
        status == 200
      end

      def query(email)
        status, body = get "nicknym.#{email.domain}", address: email.to_s
        return Nickserver::Response.new(status, body)
      end

      protected

      def get(*args)
        args[0] = "https://#{args.first}"
        adapter.get(*args)
      end
    end
  end
end
