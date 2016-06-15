require 'nickserver/invalid_source'

module Nickserver
  class Lookup

    attr_reader :nick

    def initialize(nick)
      @nick = nick
    end

    def respond_with(responder)
      query do |status, content|
        responder.send_response status: status, content: content
      end
    end

    protected

    def query(&block)
      source.query nick, &block
    end

    def source
      if nick.invalid?  then Nickserver::InvalidSource
      elsif nick.local? then Nickserver::Config.local_source
      else Nickserver::Config.remote_source
      end
    end
  end
end
