require 'test_helper'
require 'nickserver/request_handlers/local_email_handler'

class LocalEmailHandlerTest < MiniTest::Test

  def test_no_email
    assert_refuses
  end

  def test_remote_email
    assert_refuses email: 'me@remote.tld', domain: 'local.tld'
  end

  def test_local_email
    assert_handles email: 'me@local.tld', domain: 'local.tld'
  end

  def test_missing_host_header
    Nickserver::Config.stub :domain, nil do
      assert_responds_with_error "HTTP request must include a Host header.",
        email: 'me@local.tld'
    end
  end

  protected

  def handler
    Nickserver::RequestHandlers::LocalEmailHandler.new
  end

  def source
    source = Minitest::Mock.new
    source.expect :query,
      'response',
      [Nickserver::EmailAddress]
    source
  end

  def assert_handles(opts)
    Nickserver::CouchDB::Source.stub :new, source do
      assert_equal 'response', handle(request(opts))
    end
  end

  def assert_responds_with_error(msg, opts)
    response = handle(request(opts))
    assert_equal 500, response.status
    assert_equal "500 #{msg}\n", response.content
  end

  def assert_refuses(opts = {})
    assert_nil handle(request(opts))
  end

  def handle(request)
    handler.call(request)
  end

  def request(opts = {})
    params = {'address' => [opts[:email]]}
    headers = {'Host' => opts[:domain]}
    Nickserver::Request.new params, headers
  end

end
