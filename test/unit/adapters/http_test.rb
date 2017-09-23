require 'test_helper'
require 'http'
require 'nickserver/adapters/http'

class HttpAdapterTest < Minitest::Test
  def test_normal_raise
    stub_http_to_raise do
      assert_raises HTTP::ConnectionError do
        adapter.get ''
      end
    end
  end

  def test_rescueing
    stub_http_to_raise do
      assert_nil adapter.get('', rescue: 'some reason')
    end
  end

  def test_raise_not_rescued
    stub_http_to_raise do
      assert_raises Http::ConnectionError do
        assert adapter.get('', rescue: 'some other reason')
      end
    end
  end

  protected

  def stub_http_to_raise(&block)
    raises_exception = lambda { |*_args|
      raise HTTP::ConnectionError, 'for some reason'
    }
    HTTP.stub :get, raises_exception, &block
  end

  def adapter
    Nickserver::Adapters::Http.new
  end
end
