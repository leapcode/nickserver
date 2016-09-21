require 'test_helper'
require 'nickserver/dispatcher'

class Nickserver::DispatcherTest < Minitest::Test

  def test_empty_query
    handle
    assert_response not_found
  end

  def test_invalid_query
    handle address: ['asdf']
    assert_response error('Not a valid address')
  end

  def test_fingerprint_to_short
    handle fingerprint: ['44F2F455E28']
    assert_response error("Fingerprint invalid: 44F2F455E28")
  end

  def test_fingerprint_is_not_hex
    handle fingerprint: ['X36E738D69173C13Z709E44F2F455E2824D18DDX']
    assert_response error("Fingerprint invalid: X36E738D69173C13Z709E44F2F455E2824D18DDX")
  end

  def test_missing_domain
    handle address: ['valid@email.tld']
    stub_nicknym_not_available
    hkp_source.expect :query, success, [Nickserver::EmailAddress]
    assert_response success
  end

  def test_email_via_hkp
    handle address: ['valid@email.tld'], headers: { "Host" => "http://nickserver.me" }
    stub_nicknym_not_available
    hkp_source.expect :query, success, [Nickserver::EmailAddress]
    assert_response success
  end

  def test_email_via_nicknym
    handle address: ['valid@email.tld'], headers: { "Host" => "http://nickserver.me" }
    nicknym_source.expect :available_for?, true, [String]
    nicknym_source.expect :query, success, [Nickserver::EmailAddress]
    assert_response success
  end

  def test_get_key_with_fingerprint
    handle fingerprint: ['E36E738D69173C13D709E44F2F455E2824D18DDF']
    stub_nicknym_not_available
    hkp_source.expect :get_key_by_fingerprint, success,
      ['E36E738D69173C13D709E44F2F455E2824D18DDF']
    assert_response success
  end

  protected

  def handle(params = {})
    @headers = params.delete(:headers) || {}
    @params = Hash[ params.map{ |k,v| [k.to_s, v] } ]
  end

  def assert_response(response)
    Nickserver::Nicknym::Source.stub :new, nicknym_source do
      Nickserver::Hkp::Source.stub :new, hkp_source do
        responder.expect :respond, nil, [response.status, response.content]
        dispatcher.respond_to @params, @headers
        responder.verify
      end
    end
  end

  def hkp_source
    @hkp_source ||= Minitest::Mock.new
  end

  def stub_nicknym_not_available
    def nicknym_source.available_for?(*_args)
      false
    end
  end

  def nicknym_source
    @nicknym_source ||= Minitest::Mock.new
  end

  def success
    response status: 200, content: "fake content"
  end

  def not_found
    response status: 404, content: "404 Not Found\n"
  end

  def error(msg)
    response status: 500, content: "500 #{msg}\n"
  end

  def response(options)
    Nickserver::Response.new(options[:status], options[:content])
  end

  def dispatcher
    Nickserver::Dispatcher.new responder
  end

  def responder
    @responder ||= Minitest::Mock.new
  end

end
