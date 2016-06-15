class Server

  def process_http_request
    lookup.respond_with(Responder)
  end

  def lookup
    LookupFactory.lookup_for(nick)
  end

  def nick
    Nickname.new(request.address)
  end

  def request
    Request.new(params)
  end

end
