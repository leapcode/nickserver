require 'em-http'

#
# used to fetch an array of KeyInfo objects that match the given uid.
#

module Nickserver; module HKP
  class FetchKeyInfo
    include EM::Deferrable

    # for this regexp to work, the source text must end in a trailing "\n",
    # which the output of sks does.
    MATCH_PUB_KEY = /(^pub:.+?\n(^uid:.+?\n)+)/m

    def search(uid)
      # in practice, exact=on seems to have no effect
      params = {:op => 'vindex', :search => uid, :exact => 'on', :options => 'mr', :fingerprint => 'on'}
      EventMachine::HttpRequest.new(Config.sks_url).get(:query => params).callback {|http|
        if http.response_header.status != 200
          self.fail http.response_header.status
        else
          self.succeed parse(uid, http.response)
        end
      }.errback {|http|
        self.fail http.error
      }
      self
    end

    #
    # input:
    #  uid           -- uid to search for
    #  vindex_result -- raw output from a vindex hkp query (machine readable)
    #
    # returns:
    #   an array of eligible keys (as HKPKeyInfo objects) matching uid.
    #
    # keys are eliminated from eligibility for a number of reasons, including expiration,
    # revocation, uid match, key length, and so on...
    #
    def parse(uid, vindex_result)
      keys = []
      now = Time.now
      vindex_result.scan(MATCH_PUB_KEY).each do |match|
        key_info = KeyInfo.new(match[0])
        if key_info.uids.include?(uid)
          if key_info.keylen <= 1024
            #puts 'key length is too short'
          elsif key_info.expired?
            #puts 'ignoring expired key'
          elsif key_info.revoked?
            #puts 'ignoring revoked key'
          elsif key_info.disabled?
            #puts 'ignoring disabled key'
          elsif key_info.expirationdate && key_info.expirationdate < now
            #puts 'ignoring expired key'
          else
            keys << key_info
          end
        end
      end
      keys
    end
  end

end; end