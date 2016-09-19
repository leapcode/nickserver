#
# Handler Chain
#
# A chain of handlers that respond to call. Invoking handle(*args) on the chain
# will call the handlers with the given args until one of them returns a result
# that is truethy (i.e. not false or nil).
#
# Extracted from the dispatcher so we can also handle exceptions here in the
# future.
#

module Nickserver
  class HandlerChain

    def initialize(*handlers)
      @handlers = handlers
    end

    def handle(*args)
      result = nil
      _handled_by = @handlers.find{|h| result = h.call(*args)}
      result
    end

  end
end
