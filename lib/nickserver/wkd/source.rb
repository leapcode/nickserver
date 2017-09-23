require 'nickserver/source'
require 'nickserver/response'

module Nickserver
  module Wkd
    class Source < Nickserver::Source

      def query(email)
        url = Url.new(email)
        status, body = adapter.get url
        return Nickserver::Response.new(status, body)
      end

    end
  end
end
