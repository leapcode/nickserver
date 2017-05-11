require 'nickserver/response'

module Nickserver
  class ErrorResponse < Nickserver::Response
    def initialize(message)
      @status = 400
      @message = message
    end

    def content
      JSON.generate(error: message)
    end

    protected

    attr_reader :message
  end
end
