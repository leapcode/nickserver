require 'nickserver/hkp'
require 'nickserver/hkp/key_info'

#
# Simple parser for Hkp KeyInfo responses.
#
# Focus is on simple here. Trying to avoid state and sideeffects.
# Parsing a response with 12 keys and validating them takes 2ms.
# So no need for memoization and making things more complex.
module Nickserver::Hkp
  class VIndexResponse

    # for this regexp to work, the source text must end in a trailing "\n",
    # which the output of sks does.
    MATCH_PUB_KEY = /(^pub:.+?\n(^uid:.+?\n)+)/m

    #  hkp_response -- raw output from a vindex hkp query (machine readable)
    def initialize(nick, hkp_response)
      @nick = nick.to_s
      @vindex_result = hkp_response[:body]
    end

    def status
      if keys.empty?
        error_status
      else
        200
      end
    end

    def keys
      key_infos.reject { |key| error_for_key(key) }
    end

    def msg
      if errors.any?
        error_messages.join "\n"
      else
        "Could not fetch keyinfo."
      end
    end

    protected

    attr_reader :vindex_result, :nick

    def error_status
      if errors.any?
        500
      else
        404
      end
    end

    def errors
      key_infos.map{|key| error_for_key(key) }.compact
    end

    def error_messages
      key_infos.map do |key|
        err = error_for_key(key)
        error_message(key, err)
      end.compact
    end

    def key_infos
      all_key_infos.select do |key_info|
        key_info.uids.include?(nick)
      end
    end

    def all_key_infos
      @all_key_infos ||= vindex_result.scan(MATCH_PUB_KEY).map do |match|
        KeyInfo.new(match[0])
      end
    end

    def error_message(key, err)
      "Ignoring key #{key.keyid} for #{nick}: #{err}" if err
    end

    def error_for_key(key)
      if key.keylen < 2048
        "key length is too short."
      elsif key.expired?
        "key expired."
      elsif key.revoked?
        "key revoked."
      elsif key.disabled?
        "key disabled."
      elsif key.expirationdate && key.expirationdate < Time.now
        "key expired"
      end
    end
  end
end
