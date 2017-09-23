$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'kernel_ext'
require 'bundler/setup'
require 'minitest/autorun'
require 'celluloid/test'
require 'minitest/pride'

require 'nickserver/config'

TESTING = true

class Minitest::Test
  # Add global extensions to the test case class here

  def setup
    Nickserver::Config.load
  end

  def file_content(filename)
    (@file_contents ||= {})[filename] ||= File.read(file_path(filename))
  end

  def file_path(filename)
    format('%s/files/%s', File.dirname(__FILE__), filename)
  end

  def config
    Nickserver::Config
  end
end
