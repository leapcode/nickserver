require 'test_helper'
require 'nickserver/handler_chain'

class HandlerChainTest < Minitest::Test

  def test_initialization
    assert chain
  end

  def test_noop
    assert_nil chain.handle
  end

  def test_triggering_handlers
    handler_mock.expect :call, nil, [:a, :b]
    chain handler_mock
    chain.handle :a, :b
    handler_mock.verify
  end

  def test_returns_handler_result
    chain  handler_with_nil, handler_with_result
    assert_equal :result, chain.handle
  end


  protected

  def chain(*handlers)
    @chain ||= Nickserver::HandlerChain.new(*handlers)
  end

  def handler_mock
    @handler ||= Minitest::Mock.new
  end

  def handler_with_nil
    Proc.new {}
  end

  def handler_with_result
    Proc.new { :result }
  end

end
