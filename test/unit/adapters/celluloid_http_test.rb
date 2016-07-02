require 'test_helper'
require 'nickserver/adapters/celluloid_http'

class Nickserver::Adapters::CelluloidHttpTest < Minitest::Test

  def setup
    super
    Celluloid.boot
  end

  def teardown
    Celluloid.shutdown
    super
  end

  def test_successful_request
    url = 'http://url.to'
    stub_http_request(:get, url)
      .with(query: {key: :value})
      .to_return status: 200, body: 'body'
    status, body = adapter.get(url, query: {key: :value})
    assert_equal 200, status
    assert_equal 'body', body
  end

  def test_https_for_hkp
    url = Nickserver::Config.hkp_url
    real_network do
      status, _body = adapter.get url
      assert_equal 404, status
    end
  end

  protected

  def adapter
    @adapter ||= Nickserver::Adapters::CelluloidHttp.new
  end
end
