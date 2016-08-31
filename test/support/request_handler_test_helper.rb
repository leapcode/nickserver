require 'nickserver/request'

module RequestHandlerTestHelper

  protected

  def assert_refuses(opts = {})
    assert_nil handle(request(opts))
  end

  def assert_handles(opts = {})
    assert handle(request(opts))
  end

  def assert_queries_for(*query_args, &block)
    source_class.stub :new, source_expecting_query_for(*query_args), &block
  end

  def source_expecting_query_for(*query_args)
    @source ||= Minitest::Mock.new
    @source.expect :query, 'response', query_args
    @source
  end

  def assert_responds_with_error(msg, opts)
    response = handle(request(opts))
    assert_equal 500, response.status
    assert_equal "500 #{msg}\n", response.content
  end

  def handle(request)
    handler.call(request)
  end

  def request(opts = {})
    params = {'address' => [opts[:email]]}
    headers = {'Host' => opts[:domain]}
    Nickserver::Request.new params, headers
  end

end
