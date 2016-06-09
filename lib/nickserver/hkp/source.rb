require 'nickserver/hkp/response'
module Nickserver::Hkp
  class Source

    def initialize(adapter)
    end

    def query(nick)
      fetcher.get(nick).callback {|key|
        yield Response.new(nick, key)
        }.errback {|status, msg|
          yield Nickserver::Response.new(status, msg)
        }
    end

    def fetcher
      Nickserver::Hkp::FetchKey.new
    end
  end
end
