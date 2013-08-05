require 'etc'
require 'fileutils'

#
# A simple daemon, in a Debian style. Adapted from gem Dante.
#

module Nickserver
  class Daemon

    def self.run(name, &block)
      self.new.run(name, &block)
    end

    def run(name, &block)
      @name = name
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
        drop_permissions_to(Config.user) if Config.user
        File.umask 0000
        yield
      end
    end

    def create_pid_file(file, user)
      File.open file, 'w' do |f|
        f.write("#{Process.pid}\n")
      end
      FileUtils.chown(user, nil, file) if Process::Sys.getuid == 0
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
          puts "Stopped #{@name} process #{pid}."
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
      puts "Usage: #{@name} [OPTION] COMMAND"
      puts "COMMAND is one of: start, stop, restart, status, version, foreground"
      puts "OPTION is one of: --verbose"
      puts
      exit 1
    end

    def bail(msg)
      puts "#{@name.capitalize} ERROR: #{msg}."
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
          when 'start'      then ARGV.shift; @command = :start
          when 'stop'       then ARGV.shift; @command = :stop
          when 'restart'    then ARGV.shift; @command = :restart
          when 'status'     then ARGV.shift; @command = :status
          when 'version'    then ARGV.shift; @command = :version
          when 'foreground' then ARGV.shift; @command = :foreground
          when '--verbose'  then ARGV.shift; Config.versbose = true
          when /^-/         then override_default_config(ARGV.shift, ARGV.shift)
          else break
        end
      end
      usage("Missing command") unless @command
    end

    def override_default_config(flag, value)
      flag = flag.sub /^--/, ''
      if Config.respond_to?("#{flag}=")
        Config.send("#{flag}=", value)
      else
        usage("Unknown option: --#{flag}")
      end
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
      if until_true { daemon_running? }
        puts "#{@name.capitalize} started successfully."
        exit(0)
      else # Failed to start
        puts "#{@name.capitalize} couldn't be started."
        exit(1)
      end
    end

    def command_foreground(&block)
      trap("INT") do
        puts "\nShutting down..."
        exit(0)
      end
      yield
      exit(0)
    end

    def command_stop
      if daemon_running?
        kill_pid
        until_true { !daemon_running? }
      else
        puts "No #{@name} processes are running."
      end
    end

    def command_restart(&block)
      command_stop
      command_start(&block)
    end

    def command_status
      if daemon_running?
        puts "#{@name.capitalize} running, process id #{pid_from_file(Config.pid_file)}."
        exit(0)
      else
        puts "No #{@name} processes are running."
        exit(1) # must exit non-zero if not running
      end
    end

  end
end
