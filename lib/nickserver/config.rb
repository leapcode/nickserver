require 'yaml'

module Nickserver
  class Config
    PATHS = [
      File.expand_path('../../../config/default.yml', __FILE__),
      '/etc/nickserver.yml'
    ]

    class << self
      attr_accessor :hkp_url
      attr_accessor :hkp_ca_file
      attr_accessor :couch_port
      attr_accessor :couch_host
      attr_accessor :couch_database
      attr_accessor :couch_user
      attr_accessor :couch_password
      attr_accessor :port
      attr_accessor :pid_file
      attr_accessor :user
      attr_accessor :log_file
      attr_accessor :domain
      attr_accessor :domains

      attr_accessor :loaded
      attr_accessor :verbose
    end

    def self.load
      self.loaded ||= begin
        PATHS.each do |file_path|
          self.load_config(file_path)
        end
        true
      end
      self.validate
    end

    private

    def self.validate
      if @hkp_ca_file
        # look for the hkp_ca_file either by absolute path or relative to nickserver gem root
        [@hkp_ca_file, File.expand_path(@hkp_ca_file, "#{__FILE__}/../../../")].each do |file|
          if File.exist?(file)
            @hkp_ca_file = file
            break
          end
        end
        unless File.exist?(@hkp_ca_file)
          STDERR.puts "ERROR in configuration: cannot find hkp_ca_file `#{@hkp_ca_file}`"
          exit(1)
        end
      end
    end

    def self.load_config(file_path)
      begin
        YAML.load(File.read(file_path)).each do |key, value|
          begin
            self.send("#{key}=", value)
          rescue NoMethodError
            STDERR.puts "ERROR in file #{file_path}, '#{key}' is not a valid option"
            exit(1)
          end
        end
        puts "Loaded #{file_path}" if Config.verbose
      rescue Errno::ENOENT => exc
        puts "Skipping #{file_path}" if Config.verbose
      rescue Exception => exc
        STDERR.puts exc.inspect
        exit(1)
      end
    end
  end
end
