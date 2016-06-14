require 'nickserver/hkp/client'

#
# used to fetch an array of KeyInfo objects that match the given uid.
#

module Nickserver; module Hkp
  class FetchKeyInfo

    def initialize(adapter)
      @adapter = adapter
    end

    def search(uid, &block)
      client.get_key_infos_by_email(uid) do |status, response|
        parser = ParseKeyInfo.new status, response
        yield parser.status_for(uid), parser.response_for(uid)
      end
    end

    protected
    attr_reader :adapter

    def client
      @client ||= Client.new(adapter)
    end

  end

end; end
