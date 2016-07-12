#
# This class allows querying couch for public keys.
#
require 'nickserver/source'
require 'nickserver/couch_db/response'
require 'nickserver/config'

module Nickserver::CouchDB
  class Source < Nickserver::Source

    VIEW = '/_design/Identity/_view/pgp_key_by_email'

    def query(nick)
      status, body = adapter.get url, query: query_for(nick)
      Response.new(nick, status: status, body: body)
    end

    protected

    def url
      Nickserver::Config.couch_url + VIEW
    end

    def query_for(nick)
      { reduce: "false", key: "\"#{nick}\"" }
    end

    attr_reader :config
  end
end
