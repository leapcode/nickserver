require 'nickserver/adapters/celluloid_http'

module HttpAdapterHelper

  def setup
    super
    @adapter = Nickserver::Adapters::CelluloidHttp.new
  end

  def teardown
    @adapter.terminate
    super
  end

  protected

  attr_reader :adapter

end
