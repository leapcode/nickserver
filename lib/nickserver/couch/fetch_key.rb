require 'em-http'
require 'json'

module Nickserver; module Couch
  class FetchKey
    include EM::Deferrable

    def initialize(options={})
      @timeout = 5
    end

    def get(uid)
      uid = uid.split('@').first # TEMPORARY HACK FOR NOW. in the future
                                 # the database should be able to be searchable by full address
      couch_request(uid)
      self
    end

    protected

    #
    # curl http://localhost:5984/users/_design/User/_view/pgp_key_by_handle?key=%22bla%22\&reduce=false
    #
    def couch_request(uid)
      query = {"reduce" => "false", "key" => "\"#{uid}\""}
      request = EventMachine::HttpRequest.new("#{FetchKey.couch_url}/#{FetchKey.couch_view}").get(:timeout => @timeout, :query => query)
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

    def self.couch_view
      "_design/User/_view/pgp_key_by_handle"
    end

    def self.couch_url
      if Config.couch_user
        ['http://', Config.couch_user, ':', Config.couch_password, '@', Config.couch_host, ':', Config.couch_port, '/', Config.couch_database].join
      else
        ['http://', Config.couch_host, ':', Config.couch_port, '/', Config.couch_database].join
      end
    end

  end
end; end