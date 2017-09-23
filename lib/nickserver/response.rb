module Nickserver
  class Response
    attr_reader :status, :body

    def initialize(status, body)
      @status = status
      @body = body
    end

    def content
      body
    end
  end
end
