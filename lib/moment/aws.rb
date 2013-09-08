require 'aws-sdk'
# require 'log'
module Moment
  class S3

    attr_reader :keys

    # Credentials are a hash 
    # { :access_key_id => "VALID-ACCESS-KEY", :secret_access_key => "VALID-SECRET-KEY" }
    #
    def initialize(credentials)
      @keys = credentials
    end

    def connection
      # This is the AWS::S3 way of doing things.
      # @conn ||= AWS::S3::Base.establish_connection!({
      #   :access_key_id => keys.access_key_id,
      #   :secret_access_key => keys.secret_key
      # })

      # Incorporate the ENV processing into this.
      # Using the AWS ruby SDK from Amazon.
      AWS.config(access_key_id: keys.access_key_id, 
                 secret_access_key: keys.secret_key,
                 region: 'us-east-1')
      @connection = AWS::S3.new
    end

    def put_files(bucket_name, source_directory, file_list)

      if connection.nil?
        puts "******* Failed to connect to to S3"
        return
      end

      # bucket = AWS::S3::Bucket.find(bucket_name)
      # bucket = bucket.exists? ? bucket : nil
      bucket = connection.buckets[bucket_name]
      unless bucket.nil?
        file_list.each do |f|
          path = File.expand_path(f, source_directory)
          # AWS::S3::S3Object.store(f, File.open(path), bucket_name)
          bucket.objects[f].write(File.read(path))
        end
      else
        puts "Bucket: \"#{bucket.name}\" doesn't exist on this S3 account."
      end
    end
  end
end
