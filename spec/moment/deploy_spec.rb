require 'spec_helper'
require 'moment'

# Do this outside the fakefs.
keys = Moment::Keys.installed


def check_files_on_aws(bucket_name, file_list, source)
  file_list.each do |fn|
    remote = s3_conn.buckets[bucket_name].objects[fn].read
    local = File.read(source + "/" + fn)
    remote.should eq local
  end
end


describe Moment::Deploy do

  # let(:test_bucket_name){"moment_test_#{(rand*100000000).floor}"}
  let(:test_bucket_name){"moment_display_spec_test"}
  let(:s3_conn){AWS::S3.new(keys.aws_hash)}


	before do
    # Moment::FileTree.new(files, TEST_DIR_NAME).build_tree
    s3_conn.buckets.create(test_bucket_name)
  end

  after do
    # Don't forget we're using fakefs, so we don't clean up the filesystem.
    s3_conn.buckets[test_bucket_name].delete!
  end

  let(:source){"spec/fixtures/files/site_dir_1"}
  let(:file_list){["index.html"]}
  it "should copy files to the service", :vcr do
    d = Moment::Deploy.new(source, file_list, test_bucket_name, keys)
    d.deploy
    check_files_on_aws(test_bucket_name, file_list, source)
  end
end