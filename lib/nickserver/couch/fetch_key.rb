require 'em-http'
require 'json'

module Nickserver; module Couch
  class FetchKey
    include EM::Deferrable

    VIEW = "_design/Identity/_view/pgp_key_by_email"

    def initialize(options={})
      @timeout = 5
    end

    def get(uid)
      couch_request(uid)
      self
    end

    protected

    #
    # For example:
    # curl "$COUCH/identities/_design/Identity/_view/pgp_key_by_email?key=\"test1@bitmask.net\""
    #
    def couch_request(uid)
      query = {"reduce" => "false", "key" => "\"#{uid}\""}
      request = EventMachine::HttpRequest.new(FetchKey.couch_url).get(:timeout => @timeout, :query => query)
      request.callback {|http|
        if http.response_header.status != 200
          self.fail http.response_header.status, 'Unknown Error'
        else
          self.succeed parse_key_from_response(uid, http.response)
        end
      }.errback {|http|
        self.fail 0, http.error
      }
    end

    def parse_key_from_response(uid, response)
      json = JSON.load(response)
      if json["rows"].empty?
        self.fail 404, "Not Found"
      else
        return json["rows"].first["value"]
      end
    rescue Exception
      self.fail 0, "Error parsing CouchDB reply"
    end

    def self.couch_url
      @couch_url ||= begin
        url = ['http://']
        if Config.couch_user
          url.push Config.couch_user, ':', Config.couch_password, '@'
        end
        url.push Config.couch_host, ':', Config.couch_port, '/', Config.couch_database
        url.push '/', VIEW
        url.join
      end
    end

  end
end; end