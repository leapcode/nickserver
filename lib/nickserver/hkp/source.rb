require 'nickserver/source'
require 'nickserver/response'
require 'nickserver/key_response'
require 'nickserver/hkp/client'
require 'nickserver/hkp/parse_key_info'
require 'nickserver/hkp/key_info'

module Nickserver::Hkp
  #
  # Fetch keys via HKP
  # http://tools.ietf.org/html/draft-shaw-openpgp-hkp-00
  #
  class Source < Nickserver::Source
    def query(nick)
      status, response = search(nick)
      if status == 200
        best = pick_best_key(response)
        get_key_by_fingerprint(best.keyid, nick)
      elsif status != 404 # 404 means no key found and we proceed
        Nickserver::Response.new(status, response)
      end
    end

    def search(nick)
      status, response = client.get_key_infos_by_email(nick)
      parser = ParseKeyInfo.new status, response
      [parser.status_for(nick), parser.response_for(nick)]
    end

    def get_key_by_fingerprint(fingerprint, nick = nil)
      status, response = client.get_key_by_fingerprint fingerprint
      if status == 200
        Nickserver::KeyResponse.new nick, response
      else
        Nickserver::Response.new status, 'HKP Request failed'
      end
    end

    protected

    #
    # for now, just pick the newest key.
    #
    # in the future, we should perhaps pick the newest key
    # that is signed by the oldest key.
    #
    def pick_best_key(key_info_list)
      key_info_list.sort_by(&:creationdate).last
    end

    def client
      @client ||= Client.new(adapter)
    end
  end
end
