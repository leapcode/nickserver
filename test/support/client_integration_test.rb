class ClientIntegrationTest

  def setup
    super
    Celluloid.boot
  end

  def teardown
    Celluloid.shutdown
    super
  end

end
