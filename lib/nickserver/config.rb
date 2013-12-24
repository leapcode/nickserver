require 'yaml'

module Nickserver
  class Config
    PATHS = [
      File.expand_path('../../../config/default.yml', __FILE__),
      '/etc/nickserver.yml'
    ]

    class << self
      attr_accessor :hkp_url
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
    end

    private

    def self.load_config(file_path)
      begin
        YAML.load(File.read(file_path)).each do |key, value|
          begin
            self.send("#{key}=", value)
          rescue NoMethodError => exc
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
