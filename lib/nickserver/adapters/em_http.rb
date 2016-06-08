require 'nickserver/adapters'
require 'em-http'

module Nickserver::Adapters
  class EmHttp

    def initialize
      @timeout = 5
    end

    def get(url, options = {})
      get_request(url, options).callback {|http|
        yield http.response_header.status, http.response
      }.errback {|http|
        yield 0, http.error
      }
    end

    def get_request(url, options = {})
      @request = EventMachine::HttpRequest.new(url)
      @request.get timeout: @timeout, query: options[:query]
    end
  end
end
