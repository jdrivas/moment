require 'aruba/cucumber'
require 'fileutils'
require 'moment'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','lib')

Before do
  # Using "announce" causes massive warnings on 1.9.2
  # @puts = true
  # @original_rubylib = ENV['RUBYLIB']
  # ENV['RUBYLIB'] = LIB_DIR + File::PATH_SEPARATOR + ENV['RUBYLIB'].to_s
  FileUtils.rm_rf Moment::GIT_TEMP_CLONE if File.exist?(Moment::GIT_TEMP_CLONE)
  @aruba_timeout_seconds = 5
end

After do
  # ENV['RUBYLIB'] = @original_rubylib
end
