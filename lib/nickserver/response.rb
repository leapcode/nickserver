module Nickserver
  class Response

    attr_reader :status, :message

    def initialize(status, message)
      @status = status
      @message = message
    end

    def content
      "#{status} #{message}"
    end
  end
end
