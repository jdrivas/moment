require 'aws/s3'
# require 'log'
module Moment
  class S3

    attr_reader :keys

    def initialize(credentials)
      @keys = credentials
    end

    def connection
      @conn ||= AWS::S3::Base.establish_connection!({
        :access_key_id => keys.access_key_id,
        :secret_access_key => keys.secret_key
      })
    end

    def put_files(bucket_name, source_directory, file_list)

      if connection.nil?
        puts "******* Failed to connect to to S3"
        return
      end

      bucket = AWS::S3::Bucket.find(bucket_name)
      unless bucket.nil?
        puts "Updating to: #{bucket.name}"
        file_list.each do |f|
          path = File.expand_path(f, source_directory)
          puts "Updating: #{f}"
          AWS::S3::S3Object.store(f, File.open(path), bucket_name)
        end
      else
        puts "Bucket: \"#{bucket.name}\" doesn't exist on this S3 account."
      end
    end
  end
end
