require 'yaml'

module Nickserver
  class Config
    PATHS = [
      File.expand_path('../../../config/default.yml', __FILE__),
      '/etc/leap/nickserver.yml'
    ]

    class << self
      attr_accessor :sks_url
      attr_accessor :couch_port
      attr_accessor :couch_host
      attr_accessor :couch_database
      attr_accessor :port
      attr_accessor :loaded
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
        puts "Loaded #{file_path}"
      rescue Errno::ENOENT => exc
        puts "Skipping #{file_path}"
      rescue Exception => exc
        STDERR.puts exc.inspect
        exit(1)
      end
    end
  end
end
