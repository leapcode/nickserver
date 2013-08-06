require 'em-http'

#
# Fetch keys via HKP
# http://tools.ietf.org/html/draft-shaw-openpgp-hkp-00
#

module Nickserver; module HKP

  class FetchKey
    include EM::Deferrable

    def get(uid)
      FetchKeyInfo.new.search(uid).callback {|key_info_list|
        best = pick_best_key(key_info_list)
        get_key_by_fingerprint(best.keyid) {|key|
          self.succeed key
        }
      }.errback {|status, msg|
        self.fail status, msg
      }
      self
    end

    #
    # fetches ascii armored OpenPGP public key from the keyserver
    #
    def get_key_by_fingerprint(key_id)
      params = {:op => 'get', :search => "0x" + key_id, :exact => 'on', :options => 'mr'}
      http = EventMachine::HttpRequest.new(Config.hkp_url).get(:query => params)
      http.callback {
        if http.response_header.status != 200
          self.fail http.response_header.status, "HKP Request failed"
        else
          yield http.response
        end
      }
      http.errback {
        self.fail 500, http.error
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