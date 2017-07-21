require 'minitest/autorun'
require 'minitest/pride'

class FunctionalTest < Minitest::Test

  protected

  def nickserver_pid
    status = nickserver "status"
    /process id (\d*)\./.match(status)[1]
  end

  def assert_running
    status = nickserver "status"
    assert_includes status, "Nickserver running"
  end

  def assert_stopped
    status = nickserver "status"
    assert_includes status, "No nickserver processes are running."
  end

  def assert_command_runs(command)
    out = nickserver command
    assert ($?.exitstatus == 0),
      "failed to run 'nickserver #{command}':\n #{out}"
  end

  def nickserver(command)
    self.class.nickserver command
  end

  def self.nickserver(command)
    `#{path_to_executable} #{command} 2>&1`
  end

  def self.path_to_executable
    File.expand_path(File.dirname(__FILE__) + '/../../bin/nickserver')
  end

end
