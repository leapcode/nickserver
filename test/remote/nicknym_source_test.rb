require 'test_helper'
require 'nickserver/nicknym/source'

class RemoteNicknymSourceTest < Minitest::Test

  def setup
    super
    Celluloid.boot
  end

  def teardown
    Celluloid.shutdown
    super
  end

  def test_truth
    real_network do
      assert source.available_for? 'mail.bitmask.net'
    end
  end

  protected

  def source
    @source ||= Nickserver::Nicknym::Source.new
  end


end
