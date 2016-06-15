require 'nickserver/hkp'

#
# Client for the HKP protocol.
#
# This is not a complete implementation - only the parts we need.
# Instantiate with an adapter that will take care of the http requests.
#
# For each request we yield http_status and the response content just
# like the adapter does.


module Nickserver; module Hkp
  class Client

    def initialize(adapter)
      @adapter = adapter
    end

    #
    # used to fetch an array of KeyInfo objects that match the given email
    #
    def get_key_infos_by_email(email, &block)
      get op: 'vindex', search: email, fingerprint: 'on', &block
    end

    #
    # fetches ascii armored OpenPGP public key from the keyserver
    #
    def get_key_by_fingerprint(fingerprint, &block)
      get op: 'get', search: "0x" + fingerprint, &block
    end

    protected

    attr_reader :adapter

    def get(query, &block)
      # in practice, exact=on seems to have no effect
      query = {exact: 'on', options: 'mr'}.merge query
      adapter.get Config.hkp_url, query: query, &block
    end
  end
end; end
