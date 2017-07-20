require 'minitest/autorun'
require 'minitest/pride'

class BinTest < Minitest::Test

  def teardown
    run_command "stop"
  end

  def test_bin_loading
    assert_command_runs("version")
  end

  def test_not_running_by_default
    assert_stopped
  end

  def test_start
    run_command "start"
    assert_running
  end

  protected

  def assert_running
    status = run_command "status"
    assert_includes status, "Nickserver running"
  end

  def assert_stopped
    status = run_command "status"
    assert_includes status, "No nickserver processes are running."
  end

  def assert_command_runs(command)
    out = run_command command
    assert ($?.exitstatus == 0),
      "failed to run 'nickserver #{command}':\n #{out}"
  end

  def run_command(command)
    `#{path_to_executable} #{command} 2>&1`
  end

  def path_to_executable
    File.expand_path(File.dirname(__FILE__) + '/../../bin/nickserver')
  end

end
