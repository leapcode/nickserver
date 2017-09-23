require 'test_helper'
require 'file_content'
require 'support/celluloid_test'
require 'support/http_adapter_helper'
require 'nickserver/wkd/source'
require 'nickserver/email_address'

class RemoteWkdSourceTest < CelluloidTest
  include HttpAdapterHelper
  include FileContent

  def test_existing_key
    response = source.query email_with_key
    assert_equal 200, response.status
    assert_pgp_key_in response
  end

  def test_missing_key
    uid = 'thisemaildoesnotexist@test.gnupg.org'
    email = Nickserver::EmailAddress.new uid
    status, body = source.query email
    assert_nil status
    assert_nil body
  end

  protected

  def assert_pgp_key_in(response)
    json = JSON.parse response.content
    assert_equal email_with_key.to_s, json['address']
    refute_empty json['openpgp']
    assert_equal file_content('dewey.pgp.asc'), json['openpgp']
  end

  def email_with_key
    uid = 'dewey@test.gnupg.org'
    email = Nickserver::EmailAddress.new uid
  end

  def source
    Nickserver::Wkd::Source.new adapter
  end
end
