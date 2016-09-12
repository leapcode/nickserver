require 'nickserver/response'

module Nickserver
  class ErrorResponse < Nickserver::Response
    def initialize(message)
      @status = 500
      @message = message + "\n"
    end

    def content
      "#{status} #{message}"
    end

    protected

    attr_reader :message
  end
end
