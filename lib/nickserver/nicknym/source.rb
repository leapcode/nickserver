require 'nickserver/source'

module Nickserver
  module Nicknym
    class Source < Nickserver::Source

      def available_for?(domain)
        status, _body = adapter.get "https://#{domain}/provider.json"
        status == 200
      end

    end
  end
end
