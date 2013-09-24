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

vcr_options = {:record => :new_episodes}
# vcr_options = {:record => :all}
describe Moment::Deployment do

  let(:test_bucket_name){"moment_display_spec_test"}
  let(:s3_conn){AWS::S3.new(keys.aws_hash)}
  let(:deployment){Moment::Deployment.new(test_bucket_name, keys)}

  describe "deploying from a list of files" do
  	before do
      s3_conn.buckets.create(test_bucket_name)
    end

    after do
      s3_conn.buckets[test_bucket_name].delete!
    end

    let(:source){"spec/fixtures/files/site_dir_1"}
    let(:file_list){["index.html"]}
    it "should copy files to the service", :vcr => vcr_options do
      # d = Moment::Deploy.new(test_bucket_name, keys)
      deployment.deploy_file_list(source, file_list)
      check_files_on_aws(test_bucket_name, file_list, source)
    end

    it "should overwrite eixsting files", :vcr => vcr_options do
      # d = Moment::Deploy.new(test_bucket_name, keys)
      deployment.deploy_file_list(source, file_list)
      deployment.deploy_file_list("spec/fixtures/files/site_dir_2", file_list)
      check_files_on_aws(test_bucket_name, file_list, "spec/fixtures/files/site_dir_2")
    end
  end

  describe "deploy from a git repo" do
  end



end