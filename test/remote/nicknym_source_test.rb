require 'test_helper'
require 'support/celluloid_test'
require 'support/http_adapter_helper'
require 'nickserver/nicknym/source'
require 'nickserver/email_address'

#
# Please note the Readme.md file in this directory
#
class RemoteNicknymSourceTest < CelluloidTest
  include HttpAdapterHelper

  def test_available_for_mail
    source.available_for? 'mail.bitmask.net'
  rescue HTTP::ConnectionError => e
    skip e.to_s
  end

  # not a provider
  def test_not_available
    refute source.available_for? 'dl.bitmask.net'
  rescue HTTP::ConnectionError => e
    skip e.to_s
  end

  # cs.ucl.ac.uk only has an MX not an A-record
  def test_not_available_without_a_record
    refute source.available_for? 'cs.ucl.ac.uk'
  end

  def test_successful_query
    response = source.query(email_with_key)
    skip if response.status == 404
    assert_pgp_key_in response
  rescue HTTP::ConnectionError => e
    skip e.to_s
  end

  def test_not_found
    response = source.query(email_without_key)
    skip if response.status == 200
    assert_equal 404, response.status
  rescue HTTP::ConnectionError => e
    skip e.to_s
  end

  protected

  def assert_pgp_key_in(response)
    json = JSON.parse response.content
    assert_equal email_with_key.to_s, json['address']
    refute_empty json['openpgp']
  rescue JSON::ParserError
    skip "invalid json response: #{response.content}"
  end

  def source
    @source ||= Nickserver::Nicknym::Source.new adapter
  end

  def email_with_key
    Nickserver::EmailAddress.new('test@mail.bitmask.net')
  end

  def email_without_key
    Nickserver::EmailAddress.new('pleaseneverusethisemailweuseittotest@mail.bitmask.net')
  end
end
