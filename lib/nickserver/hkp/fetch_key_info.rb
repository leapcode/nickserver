require 'em-http'

#
# used to fetch an array of KeyInfo objects that match the given uid.
#

module Nickserver; module Hkp
  class FetchKeyInfo
    include EM::Deferrable

    def search(uid)
      # in practice, exact=on seems to have no effect
      params = {op: 'vindex', search: uid, exact: 'on', options: 'mr', fingerprint: 'on'}
      EventMachine::HttpRequest.new(Config.hkp_url).get(query: params).callback {|http|
        parser = ParseKeyInfo.new http.response_header, http.response
        keys = parser.keys(uid)
        if keys.any?
          self.succeed keys
        else
          self.fail parser.status(uid), parser.msg(uid)
        end
      }.errback {|http|
        self.fail 500, http.error
      }
      self
    end

  end

end; end
