require 'support/functional_test'

class SampleTest < FunctionalTest
  # don't parallize me... Hard to get that right with nickserver start & stop

  def run(*args)
    nickserver :start
    super
  ensure
    nickserver :stop
  end

  def test_running
    assert_running
  end

  # def test_invalid
  #   assert_lookup_status 400, 'invalid'
  # end

  def test_nicknym_success
    assert_lookup_status 200, 'test@mail.bitmask.net'
  end

  # Regression Tests

  # #3 handle missing A records
  def test_nicknym_handles_missing_a_record
    assert_lookup_status 404, 'postmaster@cs.ucl.ac.uk'
  end

  # platform/#8674 handle nonexisting domains
  def test_nicknym_handles_missing_domain
    assert_lookup_status 404, 'postmaster@now-dont-you-dare-register-this-domain.coop'
  end

  def test_no_file_descriptors_leak
    lookup 'test@mail.bitmask.net'
    before = open_files_count
    lookup 'test@mail.bitmask.net'
    assert_equal before, open_files_count, 'Filedescriptors leaked'
    assert (before > 0), 'Could not get filedescriptor count'
  end

  protected

  def assert_lookup_status(status, address)
    assert_equal status, lookup(address).to_i
  end

  def lookup(address)
    run_command %(curl localhost:6425 #{curl_opts} -d "address=#{address}")
  end

  def curl_opts
    '--silent -w "%{http_code}" -o /dev/null'
  end

  def open_files_count
    run_command(%(lsof | grep " #{nickserver_pid} " | wc -l)).to_i
  end

  def run_command(command)
    `#{command} 2>&1`.tap do |out|
      assert ($CHILD_STATUS.exitstatus == 0),
             "failed to run '#{command}':\n #{out}"
    end
  end
end
