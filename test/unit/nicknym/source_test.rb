require 'test_helper'
require 'nickserver/nicknym/source'
require 'nickserver/email_address'

class NicknymSourceTest < Minitest::Test

  def test_initialization
    assert source
  end

  def test_available_for_domain_with_service_mx
    assert available_on?(200, '{"services": ["mx"]}')
  end

  def test_no_provider_json_means_no_nicknym
    refute available_on?(404, 'blablabla')
  end

  def test_invalid_provider_json_means_no_nicknym
    refute available_on?(200, 'blablabla')
  end

  def test_failing_network_means_no_nicknym
    failing_network
    refute source.available_for?('remote.tld')
  end

  def test_proxy_successful_query
    assert proxies_query_response?(200, 'dummy body')
  end

  def test_proxy_query_not_found
    assert proxies_query_response?(404, 'dummy body')
  end

  protected

  def proxies_query_response?(status = 0, body = nil)
    adapter.expect :get, [status, body],
      ['https://nicknym.leap_powered.tld:6425', query: {address: email_stub.to_s}]
    response = source.query(email_stub)
    assert_equal status, response.status
    assert_equal body, response.content
    adapter.verify
  end

  def available_on?(status = 0, body = nil)
    adapter.expect :get, [status, body],
      ['https://remote.tld/provider.json']
    available = source.available_for?('remote.tld')
    adapter.verify
    return available
  end

  def failing_network
    def adapter.get(*args)
      raise HTTP::ConnectionError
    end
  end

  def source
    Nickserver::Nicknym::Source.new(adapter)
  end

  def adapter
    @adapter ||= Minitest::Mock.new
  end

  def email_stub
    @email_stub ||= Nickserver::EmailAddress.new 'test@leap_powered.tld'
  end
end
