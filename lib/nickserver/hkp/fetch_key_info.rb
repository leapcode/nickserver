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
      EventMachine::HttpRequest.new(Config.hkp_url).get(:query => params).callback {|http|
        if http.response_header.status != 200
          self.fail http.response_header.status, "Could net fetch keyinfo."
        else
          keys, errors = parse(uid, http.response)
          if keys.empty?
            self.fail 500, errors.join("\n")
          else
            self.succeed keys
          end
        end
      }.errback {|http|
        self.fail 500, http.error
      }
      self
    end

    #
    # input:
    #  uid           -- uid to search for
    #  vindex_result -- raw output from a vindex hkp query (machine readable)
    #
    # returns:
    #   an array of:
    #   [0] -- array of eligible keys (as HKPKeyInfo objects) matching uid.
    #   [1] -- array of error messages
    #
    # keys are eliminated from eligibility for a number of reasons, including expiration,
    # revocation, uid match, key length, and so on...
    #
    def parse(uid, vindex_result)
      keys = []
      errors = []
      now = Time.now
      vindex_result.scan(MATCH_PUB_KEY).each do |match|
        key_info = KeyInfo.new(match[0])
        if key_info.uids.include?(uid)
          if key_info.keylen < 2048
            errors << "Ignoring key #{key_info.keyid} for #{uid}: key length is too short."
          elsif key_info.expired?
            errors << "Ignoring key #{key_info.keyid} for #{uid}: key expired."
          elsif key_info.revoked?
            errors << "Ignoring key #{key_info.keyid} for #{uid}: key revoked."
          elsif key_info.disabled?
            errors << "Ignoring key #{key_info.keyid} for #{uid}: key disabled."
          elsif key_info.expirationdate && key_info.expirationdate < now
            errors << "Ignoring key #{key_info.keyid} for #{uid}: key expired"
          else
            keys << key_info
          end
        end
      end
      [keys, errors]
    end
  end

end; end