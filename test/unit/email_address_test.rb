require 'test_helper'
require 'nickserver/email_address'

class EmailAddressTest < Minitest::Test

  def test_domain
    nick = Nickserver::EmailAddress.new 'nick@test.me'
    assert_equal 'test.me', nick.domain
    assert nick.domain?('test.me')
    assert !nick.domain?('est.me')
  end

  def test_valid
    nick = Nickserver::EmailAddress.new 'nick@remote.domain'
    assert nick.valid?
  end

  def test_invalid
    nick = Nickserver::EmailAddress.new 'asdf'
    assert nick.invalid?
  end

end
