require 'etc'
require 'fileutils'

#
# A simple daemon, in a Debian style. Adapted from gem Dante.
#

module Nickserver
  class Daemon

    def self.run(&block)
      self.new.run(&block)
    end

    def run(&block)
      parse_options
      Config.load
      send("command_#{@command}", &block)
    end

    private

    MAX_WAIT = 2

    #
    # PERMISSIONS
    #

    #
    # see http://timetobleed.com/5-things-you-dont-know-about-user-ids-that-will-destroy-you/
    # (hint: it is easy to get it wrong)
    #
    def drop_permissions_to(username)
      if username != 'root'
        if Process::Sys.getuid == 0
          Process::Sys.setuid(Etc.getpwnam(username).uid)
          if root?
            bail "failed to drop permissions"
          end
        else
          bail "cannot change process uid to #{username}"
        end
      end
    end

    def root?
      begin
        Process::Sys.setuid(0)
      rescue Errno::EPERM
        false
      else
        true
      end
    end

    #
    # PROCESS STUFF
    #

    def daemonize
      return bail("Process is already started") if daemon_running?
      pid = fork do
        exit if fork
        Process.setsid
        exit if fork
        create_pid_file(Config.pid_file, Config.user)
        catch_interrupt
        redirect_output
        drop_permissions_to(Config.user)
        File.umask 0000
        yield
      end

      if until_true { daemon_running? }
        puts "Daemon has started successfully"
        exit(0)
      else # Failed to start
        puts "Daemon couldn't be started"
        exit(1)
      end
    end

    def create_pid_file(file, user)
      File.open file, 'w' do |f|
        f.write("#{Process.pid}\n")
      end
      FileUtils.chown(user, nil, file)
    rescue Errno::EACCES
      bail "insufficient permission to create to pid file `#{file}`"
    rescue Errno::ENOENT
      bail "bad path for pid file `#{file}`"
    rescue Errno::EROFS
      bail "can't create pid file `#{file}` on read-only filesystem"
    end

    def daemon_running?
      return false unless File.exist?(Config.pid_file)
      Process.kill 0, File.read(Config.pid_file).to_i
      true
    rescue Errno::ESRCH
      false
    end

    def pid_from_file(file)
      pid = IO.read(file).chomp
      if pid != ""
        pid.to_i
      else
        nil
      end
    end

    def kill_pid
      file = Config.pid_file
      if File.exists?(file)
        pid = pid_from_file(file)
        if pid
          Process.kill('TERM', pid)
          puts "Stopped #{pid}"
        else
          bail "Error reading pid file #{file}"
        end
        begin
          FileUtils.rm Config.pid_file
        rescue Errno::EACCES
          bail 'insufficient permission to remove pid file'
        end
      else
        bail "could not find pid file #{file}"
      end
    rescue => e
      puts "Failed to stop: #{e}"
    end

    #
    # Gracefully handle Ctrl-C
    #
    def catch_interrupt
      Signal.trap("SIGINT") do
        command_stop
        $stdout.puts "\nQuit"
        $stdout.flush
        exit
      end
    end


    #
    # OUTPUT
    #

    def usage(msg)
      puts msg
      puts
      puts "Usage: nickserver [OPTION] COMMAND"
      puts "COMMAND is one of: start, stop, restart, status, version"
      puts "OPTION is one of: --verbose"
      puts
      exit 1
    end

    def bail(msg)
      puts "Nickserver ERROR: #{msg}."
      puts "Bailing out."
      exit(1)
    end

    #
    # Redirect output based on log settings (reopens stdout/stderr to specified logfile)
    # If log_path is nil, redirect to /dev/null to quiet output
    #
    def redirect_output
      if log_path = Config.log_file
        FileUtils.mkdir_p File.dirname(log_path), :mode => 0755
        FileUtils.touch log_path
        File.chmod(0644, log_path)
        $stdout.reopen(log_path, 'a')
        $stderr.reopen $stdout
        $stdout.sync = true
      else
        # redirect to /dev/null
        $stdin.reopen '/dev/null'
        $stdout.reopen '/dev/null', 'a'
        $stderr.reopen $stdout
      end
    rescue Errno::EACCES
      bail "no permission to create log file #{log_path}"
    end

    #
    # UTILITY
    #

    #
    # Runs until the block condition is met or the timeout_seconds is exceeded
    # until_true(10) { ...return_condition... }
    #
    def until_true(timeout_seconds=MAX_WAIT, &block)
      elapsed_seconds = 0
      interval = 0.5
      while elapsed_seconds < timeout_seconds && block.call != true
        elapsed_seconds += interval
        sleep(interval)
      end
      elapsed_seconds < timeout_seconds
    end

    def parse_options
      loop do
        case ARGV[0]
          when 'start'     then ARGV.shift; @command = :start
          when 'stop'      then ARGV.shift; @command = :stop
          when 'restart'   then ARGV.shift; @command = :restart
          when 'status'    then ARGV.shift; @command = :status
          when 'version'   then ARGV.shift; @command = :version
          when '--verbose' then ARGV.shift; Config.versbose = true
          when /^-/        then usage("Unknown option: #{ARGV[0].inspect}")
          else break
        end
      end
      usage("Missing command") unless @command
    end

    #
    # COMMANDS
    #

    def command_version
      puts "nickserver #{Nickserver::VERSION}, ruby #{RUBY_VERSION}"
      exit(0)
    end

    def command_start(&block)
      daemonize(&block)
    end

    def command_stop
      if daemon_running?
        kill_pid
        until_true { !daemon_running? }
      else
        puts "No processes are running"
      end
    end

    def command_restart(&block)
      command_stop
      command_start(&block)
    end

    def command_status
      if daemon_running?
        puts "Process id #{pid_from_file(Config.pid_file)}"
      else
        puts 'Not running'
      end
    end

  end
end
