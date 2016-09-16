require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/hell'

class BinTest < Minitest::Test

  def test_bin_loading
    assert_command_runs("version")
    assert_equal 0, $?.exitstatus
  end

  protected

  def assert_command_runs(command)
    out = `#{path_to_executable} #{command} 2>&1`
    assert ($?.exitstatus == 0),
      "failed to run 'nickserver #{command}':\n #{out}"
  end

  def path_to_executable
    File.expand_path(File.dirname(__FILE__) + '/../../bin/nickserver')
  end

end
