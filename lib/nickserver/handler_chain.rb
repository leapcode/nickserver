#
# Handler Chain
#
# A chain of handlers that respond to call. Invoking handle(*args) on the chain
# will call the handlers with the given args until one of them returns a result
# that is truethy (i.e. not false or nil).
#
# You can specify exception classes to rescue with
#   handler_chain.continue_on ErrorClass1, ErrorClass2
# These exceptions will be rescued and tracked. The chain will proceed even if
# one handler raised the given exception. Afterwards you can inspect them with
#   handler_chain.rescued_exceptions
#

module Nickserver
  class HandlerChain

    def initialize(*handlers)
      @handlers = handlers
      @exceptions_to_rescue = []
      @rescued_exceptions = []
    end

    def continue_on(*exceptions)
      self.exceptions_to_rescue += exceptions
    end

    def handle(*args)
      result = nil
      _handled_by = @handlers.find{|h| result = try_handler(h, *args)}
      result
    end

    attr_reader :rescued_exceptions

    protected

    attr_writer :rescued_exceptions
    attr_accessor :exceptions_to_rescue

    def try_handler(handler, *args)
      result = handler.call(*args)
    rescue *exceptions_to_rescue
      self.rescued_exceptions << $!
      result = false
    end
  end
end
