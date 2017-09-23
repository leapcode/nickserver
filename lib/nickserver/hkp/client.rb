require 'nickserver/hkp'

module Nickserver::Hkp
  #
  # Client for the HKP protocol.
  #
  # This is not a complete implementation - only the parts we need.
  # Instantiate with an adapter that will take care of the http requests.
  #
  # For each request we yield http_status and the response content just
  # like the adapter does.
  class Client
    def initialize(adapter)
      @adapter = adapter
    end

    #
    # used to fetch an array of KeyInfo objects that match the given email
    #
    def get_key_infos_by_email(email)
      get op: 'vindex', search: email.to_s, fingerprint: 'on'
    end

    #
    # fetches ascii armored OpenPGP public key from the keyserver
    #
    def get_key_by_fingerprint(fingerprint)
      get op: 'get', search: '0x' + fingerprint
    end

    protected

    attr_reader :adapter

    def get(query)
      # in practice, exact=on seems to have no effect
      query = { exact: 'on', options: 'mr' }.merge query
      response = adapter.get Config.hkp_url, query: query
      response
    end
  end
end
