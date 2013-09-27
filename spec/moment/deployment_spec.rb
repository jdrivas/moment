require 'spec_helper'
require 'moment'


# Generally this only needs to get set up 
# The first time this test is run in a new local repository.
TEMP_DIR = "spec/fixtures/tmp"
unless File.exists?(TEMP_DIR)
  Dir.mkdir(TEMP_DIR)
end

GIT_REPO_DIR = "spec/fixtures/files/git_test_repo"
GIT_REPO_FILE = File.expand_path(".git", GIT_REPO_DIR)
GIT_REPO_SOURCE_DIR = "spec/fixtures/files/site_dir_3"

unless File.exists?(GIT_REPO_DIR)
  FileUtils.cp_r(GIT_REPO_SOURCE_DIR, GIT_REPO_DIR)
  Dir.chdir(GIT_REPO_DIR) do
    system "git init && git add . && git commit -m 'first commit'"
  end

end



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
  let(:keys){Moment::Keys.installed}
  let(:test_bucket_name){"moment_display_spec_test"}
  let(:s3_conn){AWS::S3.new(keys.aws_hash)}
  let(:deployment){Moment::Deployment.new(test_bucket_name, keys)}
  before do
    s3_conn.buckets.create(test_bucket_name)
  end

  after do
    s3_conn.buckets[test_bucket_name].delete!
  end


  describe "deploying from a list of files", :vcr => vcr_options do

    let(:source){"spec/fixtures/files/site_dir_1"}
    let(:file_list){["index.html"]}
    it "should copy files to the service", :vcr => vcr_options do
      deployment.deploy_file_list(source, file_list)
      check_files_on_aws(test_bucket_name, file_list, source)
    end

    it "should overwrite eixsting files", :vcr => vcr_options do
      deployment.deploy_file_list(source, file_list)
      deployment.deploy_file_list("spec/fixtures/files/site_dir_2", file_list)
      check_files_on_aws(test_bucket_name, file_list, "spec/fixtures/files/site_dir_2")
    end
  end

  describe "deploy from a git repo", :vcr => vcr_options do

    let(:source){"site"}
    let(:repo_dir){TEMP_DIR + "/git_test_repo"}

    after do
      deployment.temp_repo_cleanup(repo_dir)
    end

    it "should copy files over from a local repo" do 
      repo = GIT_REPO_DIR
      deployment.silent = true
      deployment.deploy_repo(repo, :master, source, repo_dir, false)

      local_path = File.expand_path(source, repo_dir)
      files = Moment::Files.get_file_list local_path
      check_files_on_aws(test_bucket_name, files, local_path)
    end

    # THIS IS EXPENSIVE IT GOES TO A GIT REPO ON GITHUB.
    it "should copy files over from a remote repo" do
      pending "This goes out on the net and clones a git repo. Put this in a CI"
      repo = "ssh://git@bitbucket.org/jdrivas/moment_test_repo_1.git"
      deployment.deploy_repo(repo, :master, source, repo_dir, false)

      local_path = File.expand_path(source, repo_dir)
      files = Moment::Files.get_file_list local_path
      check_files_on_aws(test_bucket_name, files, local_path)
    end

  end
end