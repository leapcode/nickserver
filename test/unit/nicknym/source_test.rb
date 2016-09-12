require 'test_helper'
require 'nickserver/nicknym/source'
require 'nickserver/email_address'

class NicknymSourceTest < Minitest::Test

  def test_initialization
    assert source
  end

  def test_available_for_domain
    adapter.expect :get, [200, 'dummy body'],
      ['https://leap_powered.tld/provider.json']
    assert source.available_for?('leap_powered.tld')
    adapter.verify
  end

  def test_not_available_for_domain
    adapter.expect :get, [404, nil],
      ['https://remote.tld/provider.json']
    assert !source.available_for?('remote.tld')
    adapter.verify
  end

  def test_successful_query
    adapter.expect :get, [200, 'dummy body'],
      ['https://nicknym.leap_powered.tld', address: email_stub.to_s]
    response = source.query(email_stub)
    assert_equal 200, response.status
    assert_equal 'dummy body', response.content
    adapter.verify
  end

  protected

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
