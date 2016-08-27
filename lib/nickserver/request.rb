module Nickserver
  class Request
    def initialize(params, headers)
      @params = params || {}
      @headers = headers
    end

    def email
      param("address")
    end

    def fingerprint
      param("fingerprint")
    end

    def domain
      host_header = headers['Host'] || ''
      domain_part = host_header.split(':')[0] || ''
      domain_part.strip.sub(/^nicknym\./, '')
    end

    protected

    def param(key)
      params[key] && params[key].first
    end

    attr_reader :params, :headers
  end
end
