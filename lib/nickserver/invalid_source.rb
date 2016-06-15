#
# This is a dummy source for invalid queries.
# It simply always returns 500 and "Not a valid address"
#

module Nickserver
  class InvalidSource

    def query(nick)
      yield 500, "Not a valid address"
    end

  end
end
