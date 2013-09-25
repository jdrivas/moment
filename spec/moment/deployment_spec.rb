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
  before do
    s3_conn.buckets.create(test_bucket_name)
  end

  after do
    s3_conn.buckets[test_bucket_name].delete!
  end


  describe "deploying from a list of files" do

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

  describe "deploy from a git repo", :vcr => vcr_options do

    let(:source){"site"}
    let(:repo_dir){"spec/fixtures/tmp/git_test_repo"}

    after do
      deployment.temp_repo_cleanup(repo_dir)
    end

    it "should copy files over from a local repo" do 
      repo = "spec/fixtures/files/git_repo_1"
      deployment.deploy_repo(repo, :master, source, repo_dir, false)

      local_path = File.expand_path(source, repo_dir)
      files = Moment::Files.get_file_list local_path
      check_files_on_aws(test_bucket_name, files, local_path)
    end

    it "should copy files over from a remote repo" do
      repo = "ssh://git@bitbucket.org/jdrivas/moment_test_repo_1.git"
      deployment.deploy_repo(repo, :master, source, repo_dir, false)

      local_path = File.expand_path(source, repo_dir)
      files = Moment::Files.get_file_list local_path
      check_files_on_aws(test_bucket_name, files, local_path)
    end

  end



end