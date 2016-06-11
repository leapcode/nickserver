require 'nickserver/response'
require 'nickserver/hkp/response'

#
# Fetch keys via HKP
# http://tools.ietf.org/html/draft-shaw-openpgp-hkp-00
#

module Nickserver; module Hkp
  class Source

    def initialize(adapter)
      @adapter = adapter
    end

    def query(nick, &block)
      FetchKeyInfo.new(adapter).search(nick) do |status, response|
        if status == 200
          best = pick_best_key(response)
          get_key_by_fingerprint(nick, best.keyid, &block)
        else
          yield Nickserver::Response.new(status, response)
        end
      end
    end

    protected

    attr_reader :adapter

    #
    # fetches ascii armored OpenPGP public key from the keyserver
    #
    def get_key_by_fingerprint(nick, key_id)
      params = {op: 'get', search: "0x" + key_id, exact: 'on', options: 'mr'}
      adapter.get Config.hkp_url, query: params do |status, response|
        if status == 200
          yield Response.new nick, response
        else
          yield Nickserver::Response.new status, "HKP Request failed"
        end
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
      key_info_list.sort {|a,b| a.creationdate <=> b.creationdate}.last
    end
  end

end; end
