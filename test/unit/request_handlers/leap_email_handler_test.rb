require 'test_helper'
require 'support/request_handler_test_helper'
require 'nickserver/request_handlers/leap_email_handler'

class LeapEmailHandlerTest < MiniTest::Test
  include RequestHandlerTestHelper

  def test_no_email
    assert_refuses
  end

  def test_local_email
    assert_refuses email: 'me@local.tld', domain: 'local.tld'
  end

  def test_remote_email
    source ||= Minitest::Mock.new
    source.expect :available_for?, false, ['remote.tld']
    source_class.stub :new, source do
      assert_refuses email: 'me@remote.tld', domain: 'local.tld'
    end
  end

  def test_nicknym_email
    @source ||= Minitest::Mock.new
    @source.expect :available_for?, true, ['nicknym.tld']
    assert_queries_for Nickserver::EmailAddress do
      assert_handles email: 'me@nicknym.tld', domain: 'local.tld'
    end
  end

  protected

  def handler
    Nickserver::RequestHandlers::LeapEmailHandler
  end

  def source_class
    Nickserver::Nicknym::Source
  end
end
