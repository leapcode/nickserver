module Nickserver
  class Config
    class << self
      attr_accessor :sks_url
      attr_accessor :port
    end
  end

  #
  # set reasonable defaults
  #
  Config.sks_url = 'https://hkps.pool.sks-keyservers.net:/pks/lookup'
  Config.port = 6425 # aka "NICK"
end
