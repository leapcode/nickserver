require 'test_helper'
require 'nickserver/nickname'

class NicknameTest < Minitest::Test

  def test_local
    nick = Nickserver::Nickname.new 'nick@test.me'
    assert nick.local?
    assert !nick.remote?
  end

  def test_remote
    nick = Nickserver::Nickname.new 'nick@remote.domain'
    assert !nick.local?
    assert nick.remote?
  end

  def test_valid
    nick = Nickserver::Nickname.new 'nick@remote.domain'
    assert nick.valid?
  end

  def test_invalid
    nick = Nickserver::Nickname.new 'asdf'
    assert nick.invalid?
  end

end
