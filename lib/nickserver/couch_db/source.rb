#
# This class allows querying couch for public keys.
#
require 'nickserver/source'
require 'nickserver/couch_db/response'
require 'nickserver/config'

module Nickserver::CouchDB
  class Error < StandardError; end

  class Source < Nickserver::Source

    VIEW = '/_design/Identity/_view/pgp_key_by_email'
    UNEXPECTED_RESPONSE_CODES = [401, 500]

    def query(nick)
      status, body = adapter.get url, query: query_for(nick)
      handle_unexpected_responses(status, body)
      Response.new(nick, status: status, body: body)
    end

    protected

    def handle_unexpected_responses(status, body)
      if UNEXPECTED_RESPONSE_CODES.include? status
        raise Error.new("Couch responded with #{status}: #{body}")
      end
    end

    def url
      Nickserver::Config.couch_url + VIEW
    end

    def query_for(nick)
      { reduce: "false", key: "\"#{nick}\"" }
    end

    attr_reader :config
  end
end
