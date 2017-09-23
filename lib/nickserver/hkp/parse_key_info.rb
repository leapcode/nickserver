module Nickserver::Hkp
  #
  # Simple parser for Hkp KeyInfo responses.
  #
  # Focus is on simple here. Trying to avoid state and sideeffects.
  # Parsing a response with 12 keys and validating them takes 2ms.
  # So no need for memoization and making things more complex.
  #
  class ParseKeyInfo
    # for this regexp to work, the source text must end in a trailing "\n",
    # which the output of sks does.
    MATCH_PUB_KEY = /(^pub:.+?\n(^uid:.+?\n)+)/m

    #  status        -- http status of the hkp response
    #  vindex_result -- raw output from a vindex hkp query (machine readable)
    def initialize(status, vindex_result)
      @status = status
      @vindex_result = vindex_result
    end

    def status_for(email)
      uid = email.to_s
      if hkp_ok? && keys(uid).empty?
        error_status(uid)
      else
        status
      end
    end

    def response_for(email)
      uid = email.to_s
      if keys(uid).any?
        keys(uid)
      else
        msg(uid)
      end
    end

    protected

    def keys(uid)
      key_infos(uid).reject(&:error)
    end

    def msg(uid)
      if errors(uid).any?
        error_messages(uid).join "\n"
      else
        'Could not fetch keyinfo.'
      end
    end

    attr_reader :status
    attr_reader :vindex_result

    def error_status(uid)
      if errors(uid).any?
        500
      else
        404
      end
    end

    def errors(uid)
      key_infos(uid).map(&:error).compact
    end

    def error_messages(uid)
      key_infos(uid).map do |key|
        error_message(uid, key)
      end.compact
    end

    def key_infos(uid)
      all_key_infos.select do |key_info|
        key_info.uids.include?(uid)
      end
    end

    def all_key_infos
      # only parse hkp responses with status 200 (OK)
      return [] unless hkp_ok?
      @all_key_infos ||= vindex_result.scan(MATCH_PUB_KEY).map do |match|
        KeyInfo.new(match[0])
      end
    end

    def hkp_ok?
      status == 200
    end

    def error_message(uid, key)
      "Ignoring key #{key.keyid} for #{uid}: #{key.error}" if key.error
    end
  end
end
