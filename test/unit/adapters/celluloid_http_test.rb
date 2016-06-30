require 'test_helper'
require 'nickserver/adapters/celluloid_http'
require 'celluloid/test'

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
    adapter.get(url, query: {key: :value}) do |status, body|
      assert_equal 200, status
      assert_equal 'body', body
    end
  end

  protected

  def adapter
    @adapter ||= Nickserver::Adapters::CelluloidHttp.new
  end
end
