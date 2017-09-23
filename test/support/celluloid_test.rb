class CelluloidTest < Minitest::Test
  def setup
    super
    Celluloid.boot
    Celluloid.logger = nil
  end

  def teardown
    Celluloid.shutdown
    super
  end
end
