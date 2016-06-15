require 'testhelper'
require 'nickserver/adapters/couch_db'

class Nickserver::Adapters::CouchDBTest < Minitest::Test

  def test_query_404
    adapter.query(nil) do |status, content|
      assert_equal 404, status
    end
  end

  def adapter
    @adapter ||= Nickserver::Adapters::CouchDB.new
  end
end
