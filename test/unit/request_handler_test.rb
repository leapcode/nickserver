require 'test_helper'
require 'nickserver/request_handler'

class Nickserver::RequestHandlerTest < Minitest::Test

  def test_empty_query
    handle
    assert_response status: 404, content: "404 Not Found\n"
  end

  def test_invalid_query
    handle address: ['asdf']
    assert_response status: 500, content: "500 Not a valid address\n"
  end

  def test_missing_domain
    handle address: ['valid@email.tld']
    assert_response status: 500, content: "500 HTTP request must include a Host header.\n"
  end

  protected

  def handle(params = {}, headers = {})
    @params = Hash[ params.map{ |k,v| [k.to_s, v] } ]
    @headers = headers
  end

  def assert_response(args)
    responder.expect :respond, nil, [args[:status], args[:content]]
    handler.respond_to @params, @headers
    responder.verify
  end

  def handler
    Nickserver::RequestHandler.new responder, adapter
  end

  def responder
    @responder ||= Minitest::Mock.new
  end

  def adapter
    @adapter ||= Minitest::Mock.new
  end
end
