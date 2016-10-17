require 'test_helper'
require 'support/celluloid_test'
require 'nickserver/adapters/celluloid_http'

class Nickserver::Adapters::CelluloidHttpTest < CelluloidTest

  def test_https_for_hkp
    url = Nickserver::Config.hkp_url
    status, _body = adapter.get url
    assert_equal 404, status
  rescue HTTP::ConnectionError => e
    skip "could not talk to hkp server: #{e}"
  end

  protected

  def adapter
    @adapter ||= Nickserver::Adapters::CelluloidHttp.new
  end
end
