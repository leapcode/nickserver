require 'test_helper'
require 'nickserver/request'

class Nickserver::RequestTest < Minitest::Test
  def test_email
    request = request_with_params address: fake_email
    assert_equal fake_email, request.email
  end

  def test_blank_email
    request = request_with_params
    assert_nil request.email
  end

  def test_fingerprint
    request = request_with_params fingerprint: fake_fingerprint
    assert_equal fake_fingerprint, request.fingerprint
  end

  def test_domain
    request = Nickserver::Request.new({}, 'Host' => ' nicknym.my.domain.tld:123')
    assert_equal 'my.domain.tld', request.domain
  end

  protected

  # params are encoded with strings as keys and arrays with the
  # given value(s)
  def request_with_params(params = {})
    params = params.collect { |k, v| [k.to_s, Array(v)] }.to_h
    Nickserver::Request.new params, {}
  end

  def fake_email
    'test@domain.tld'
  end

  def fake_fingerprint
    'F' * 40
  end
end
