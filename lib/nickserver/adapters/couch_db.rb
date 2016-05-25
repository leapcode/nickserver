require 'nickserver/adapters'

class Nickserver::Adapters::CouchDB


  protected

  def query_couch(nick)
    yield 404, "{}"
  end

end
