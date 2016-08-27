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

  def test_email_from_hkp
    handle address: ['valid@email.tld'], headers: { "Host" => "http://nickserver.me" }
    source = Minitest::Mock.new
    source.expect :query, Nickserver::Response.new(200, "fake content"), [Nickserver::EmailAddress]
    Nickserver::Hkp::Source.stub :new, source do
      assert_response status: 200, content: "200 fake content"
    end
  end

  def test_fingerprint_to_short
    handle fingerprint: ['44F2F455E28']
    assert_response status: 500, content: "500 Fingerprint invalid: 44F2F455E28\n"
  end

  def test_fingerprint_is_not_hex
    handle fingerprint: ['X36E738D69173C13Z709E44F2F455E2824D18DDX']
    assert_response status: 500,
      content: "500 Fingerprint invalid: X36E738D69173C13Z709E44F2F455E2824D18DDX\n"
  end

  def test_get_key_with_fingerprint_from_hkp
    handle fingerprint: ['E36E738D69173C13D709E44F2F455E2824D18DDF']
    source = Minitest::Mock.new
    source.expect :get_key_by_fingerprint,
      Nickserver::Response.new(200, "fake fingerprint"),
      ['E36E738D69173C13D709E44F2F455E2824D18DDF']
    Nickserver::Hkp::Source.stub :new, source do
      assert_response status: 200, content: "200 fake fingerprint"
    end
  end

  protected

  def handle(params = {})
    @headers = params.delete(:headers) || {}
    @params = Hash[ params.map{ |k,v| [k.to_s, v] } ]
  end

  def assert_response(args)
    responder.expect :respond, nil, [args[:status], args[:content]]
    handler.respond_to @params, @headers
    responder.verify
  end

  def handler
    Nickserver::RequestHandler.new responder
  end

  def responder
    @responder ||= Minitest::Mock.new
  end

end
