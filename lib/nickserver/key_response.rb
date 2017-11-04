module Nickserver
  class KeyResponse
    attr_reader :status, :content

    def initialize(uid, key)
      @content = format_response(address: uid, openpgp: key)
      @status = 200
    end

    protected

    def format_response(map)
      map.to_json
    end
  end
end
