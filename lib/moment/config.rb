require 'yaml'
module Moment


  class Configuration

    attr_accessor :file_name
    attr_accessor :hash

    def initialize(file_name)
      @file_name = file_name
    end

    # Note: I couuld turn this into a hash directly and make the interface 
    # a bit simpler, but it's only used once in the main program to merge
    # in values, so I'm comfortable with this now.
    def configuration
      if File.exists?(@file_name)
        # Why the YAML load returns a nil on an empty well foramted
        # file, I'll never know.
        @hash ||= (YAML.load_file(@file_name) || {})
      else
        @hash = {}
      end
      @hash
    end
  end

  # This is the preffred way of maniulatping the apps configuration.
  # Commands to manage configurations within moment. 
  # Does this smell bad? Should I move these to Moment::Configuration?
  DEFAULT_CONFIG_PATH=File.expand_path(".", ".moment.yaml")

  def self.default_configuration_path
    return DEFAULT_CONFIG_PATH
  end

  # Gets the current conifguration
  def self.get_configuration
    @@config = Moment::Configuration.new(default_configuration_path)
  end

  # Bootstraps a new config
  def self.create_configuration(force=false, config_path=nil)
    config_path ||= default_configuration_path
    if File.exists?(config_path) && !force
      raise ArgumentError.new "Trying to overwrite configuration: \"#{config_path}\""
    else
      new_config(config_path)
    end
  end

@private
  # intended to only be called here.
  def self.new_config(config_path)
    File.open(config_path, 'w') { |f| f.puts Moment::DEFAULT_CONFIG_CONTENT }
  end

  DEFAULT_CONFIG_CONTENT = <<EOS
---
# You can have as many environments as you want
# uncomment the following to add them
:environments:
  :production: 
    :endpoint: moment-site
    :repo: git@github.com:my_git_account/moment-test-site.git
    :branch: master

  :staging:
    :endpoint: staging.moment-site
    :repo: git@github:my_git_account/moment-test-site.git
    :branch: staging

# You can also redefine the directory that contains your
# site:
:directory: my_site
#
# And the template engine
#:build: {
#  template_type: simple_php
#}
EOS

end
