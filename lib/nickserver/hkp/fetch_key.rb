require 'em-http'
require 'nickserver/response'
require 'nickserver/hkp/response'

#
# Fetch keys via HKP
# http://tools.ietf.org/html/draft-shaw-openpgp-hkp-00
#

module Nickserver; module Hkp

  class FetchKey

    def initialize(adapter)
      @adapter = adapter
    end

    def get(nick, &block)
      FetchKeyInfo.new.search(nick).callback {|key_info_list|
        best = pick_best_key(key_info_list)
        get_key_by_fingerprint(nick, best.keyid, &block)
      }.errback {|status, msg|
        yield Nickserver::Response.new(status, msg)
      }
    end

    #
    # fetches ascii armored OpenPGP public key from the keyserver
    #
    def get_key_by_fingerprint(nick, key_id)
      params = {op: 'get', search: "0x" + key_id, exact: 'on', options: 'mr'}
      http = EventMachine::HttpRequest.new(Config.hkp_url).get(query: params)
      http.callback {
        status = http.response_header.status
        if status != 200
          yield Nickserver::Response.new status, "HKP Request failed"
        else
          yield Response.new nick, http.response
        end
      }
      http.errback {
        yield Nickserver::Response.new 500, http.error
      }
    end

    protected

    #
    # for now, just pick the newest key.
    #
    # in the future, we should perhaps pick the newest key
    # that is signed by the oldest key.
    #
    def pick_best_key(key_info_list)
      key_info_list.sort {|a,b| a.creationdate <=> b.creationdate}.last
    end
  end

end; end
