require 'test_helper'
require 'support/request_handler_test_helper'
require 'nickserver/request_handlers/local_email_handler'

class LocalEmailHandlerTest < MiniTest::Test
  include RequestHandlerTestHelper

  def test_no_email
    assert_refuses
  end

  def test_remote_email
    assert_refuses email: 'me@remote.tld', domain: 'local.tld'
  end

  def test_local_email
    assert_queries_for Nickserver::EmailAddress do
      assert_handles email: 'me@local.tld', domain: 'local.tld'
    end
  end

  def test_missing_host_header
    assert_refuses email: 'me@local.tld'
  end

  protected

  def handler
    Nickserver::RequestHandlers::LocalEmailHandler
  end

  def source_class
    Nickserver::CouchDB::Source
  end

end
