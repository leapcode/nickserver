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
    handler_mock.expect :call, nil, %i[a b]
    chain handler_mock
    chain.handle :a, :b
    handler_mock.verify
  end

  def test_returns_handler_result
    chain handler_with_nil, handler_with_result
    assert_equal :result, chain.handle
  end

  def test_raise_exception
    chain handler_raising, handler_with_result
    assert_raises RuntimeError do
      chain.handle
    end
  end

  def test_continue_on_exception
    chain handler_raising, handler_with_result
    chain.continue_on(RuntimeError)
    assert_equal :result, chain.handle
    assert_equal [RuntimeError], chain.rescued_exceptions.map(&:class)
  end

  def test_continue_on_exception_with_nil
    chain handler_raising, handler_with_nil
    chain.continue_on(RuntimeError)
    assert_nil chain.handle
    assert_equal [RuntimeError], chain.rescued_exceptions.map(&:class)
  end

  protected

  def chain(*handlers)
    @chain ||= Nickserver::HandlerChain.new(*handlers)
  end

  def handler_mock
    @handler ||= Minitest::Mock.new
  end

  def handler_with_nil
    proc {}
  end

  def handler_with_result
    proc { :result }
  end

  def handler_raising(exception = RuntimeError)
    proc { raise exception }
  end
end
