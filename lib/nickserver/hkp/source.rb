module Nickserver::Hkp
  class Source

    def initialize(adapter)
      @adapter = adapter
    end

    def query(nick, &block)
      fetcher.get(nick, &block)
    end

    protected

    attr_reader :adapter

    def fetcher
      Nickserver::Hkp::FetchKey.new(adapter)
    end
  end
end
