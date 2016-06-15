require 'test_helper'
require 'nickserver/adapters/em_http'

class Nickserver::Adapters::EmHttpTest < Minitest::Test

  def test_successful_request
    url = 'http://url.to'
    stub_http_request(:get, url)
      .with(query: {key: :value})
      .to_return status: 200, body: 'body'
    EM.run do
      adapter.get(url, query: {key: :value}) do |status, body|
        assert_equal 200, status
        assert_equal 'body', body
        EM.stop
      end
    end
  end

  protected

  def adapter
    Nickserver::Adapters::EmHttp.new
  end
end
