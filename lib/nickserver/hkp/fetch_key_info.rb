#
# used to fetch an array of KeyInfo objects that match the given uid.
#

module Nickserver; module Hkp
  class FetchKeyInfo

    def initialize(adapter)
      @adapter = adapter
    end

    def search(uid, &block)
      # in practice, exact=on seems to have no effect
      params = {op: 'vindex', search: uid, exact: 'on', options: 'mr', fingerprint: 'on'}
      adapter.get(Config.hkp_url, query: params) do |status, response|
        parser = ParseKeyInfo.new status, response
        yield parser.status_for(uid), parser.response_for(uid)
      end
    end

    protected
    attr_reader :adapter

  end

end; end
