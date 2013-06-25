require 'yaml'
module Moment

  CONFIG_PATH=File.expand_path(".", ".moment.yaml")

  def self.config
    @@config = Moment::Configuration.new(CONFIG_PATH)
  end

  class Configuration

    def initialize(file_name)
      @file_name = file_name
    end

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

  def self.create_config(force=false)
    if File.exists?(CONFIG_PATH) && !force
      puts "Configuration file #{@file_name} already exsits."
      puts "to overwrite use: moment init --force"
    else
      new_config
    end
  end

  def self.new_config
    File.open(CONFIG_PATH, 'w') { |f| f.puts Moment::DEFAULT_CONFIG_CONTENT }
  end

  DEFAULT_CONFIG_CONTENT = <<EOS
---
# You can have as many environments as you want
# uncomment the following to add them
:environments: {
  production: moment-site,
  staging: staging.moment-site
}

# You can also redefine the directory that contains your
# site:
#:directory: my_site
#
EOS

end
