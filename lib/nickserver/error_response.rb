require 'nickserver/response'

module Nickserver
  class ErrorResponse < Nickserver::Response
    def initialize(message)
      @status = 500
      @message = message + "\n"
    end

  end
end
