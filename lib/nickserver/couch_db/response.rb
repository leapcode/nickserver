require 'nickserver/couch_db'
require 'json'

module Nickserver::CouchDB
  class Response

    def initialize(nick, couch_response = {})
      @nick = nick
      @couch_status = couch_response[:status]
      @json = JSON.load(couch_response[:body]) if couch_status == 200
    end

    def status
      if ok? && empty? then 404
      else couch_status
      end
    end

    def content
      key_response if ok? && !empty?
    end

    protected

    def key_response
      format address: nick.to_s, openpgp: key
    end

    def format(response)
      response.to_json
    end

    def key
      rows.first["value"]
    end

    def ok?
      couch_status == 200
    end

    def empty?
      rows.empty?
    end

    def rows
      json["rows"]
    end

    attr_reader :couch_status, :json, :nick
  end
end
