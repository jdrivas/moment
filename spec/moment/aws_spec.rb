require 'spec_helper'
require 'moment'

describe Moment::S3 do
	let(:test_bucket_name){"moment_test"}
	let(:aws_keys){Moment::Keys.installed}
	let(:aws_conn){AWS::S3.new(aws_keys.aws_hash)}
	let(:s3){Moment::S3.new(aws_keys)}

	before do
		aws_conn.buckets.create(test_bucket_name)
	end

	it "should succesfully put a file up on Amazon", :vcr  do
		test_file_name = "fixtures/files/test-data.txt"
		s3.put_files(test_bucket_name, "spec", [test_file_name])
		remote = aws_conn.buckets[test_bucket_name].objects[test_file_name].read
	  local = File.read("spec/" + test_file_name)
	  remote.should eq local
	end

	it "should succesfully put multiple files up on Amazon", :vcr do
		test_files = [1,2].each_with_object([]) {|i,a| a.push "fixtures/files/test_file_#{i}.txt"}
		s3.put_files(test_bucket_name, 'spec', test_files)
		test_files.each do |fn|
			remote = aws_conn.buckets[test_bucket_name].objects[fn].read
			local = File.read("spec/" + fn)
			remote.should eq local
		end
	end

end

