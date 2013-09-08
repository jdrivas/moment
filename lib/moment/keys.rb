require 'yaml'
module Moment

  class Keys

    INSTALL_FILE_NAME = ".aws_credentials"
    ACCESS_KEY = "aws_access_key_id"
    SECRET_KEY = "aws_secret_key"

    attr_accessor :access_key_id, :secret_key, :region

    # Get credentials that are installed
    # in local a yaml file.
    def self.installed
      key_hash = YAML.load_file(Keys.install_filename)
      Keys.new(key_hash[ACCESS_KEY], key_hash[SECRET_KEY])
    end 

    # Name of file where we'll be installing or looking for installed creds.
    def self.install_filename
      return INSTALL_FILE_NAME
    end

    # TODO: Decide if/where to put default region configuration informaiton.
    def initialize (aws_access_key_id, aws_secret_key)
      self.access_key_id = aws_access_key_id
      self.secret_key = aws_secret_key
    end

    # Put these keys into a local YAML file.
    # and set permissions on it to user only read/write.
    def install
      File.open(Keys.install_filename, "w") do |f|
        f.write({
          ACCESS_KEY => self.access_key_id,
          SECRET_KEY => self.secret_key
          }.to_yaml)
      end
      Pathname.new(Keys.install_filename).chmod(0600)
    end

    def aws_hash(region="us-east-1")
      {access_key_id: access_key_id, secret_access_key: secret_key, region: region}
    end
  end
end