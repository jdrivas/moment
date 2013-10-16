require 'spec_helper'
require 'moment'
require 'rugged'

## 
# THESE ARE REALLY INTEGRATION TESTS NOT 'UNIT' TESTS
# BUT THEY ARE IN THE MIDDLE OF THE CURRENT DEVELOPMENT CYCLE
# SO HERE THEY SHALL REMAIN FOR NOW.
##

# Generally this only needs to get set up 
# the first time this suite is run in a new local repository.
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


# Preconifgured VCR options
vcr_only_update_new = {:record => :new_episodes}
vcr_always_update = {:record => :all}
vcr_default = vcr_only_update_new
vcr_dev = vcr_always_update

vcr_current = vcr_default

describe Moment::Deployment do
  let(:keys){Moment::Keys.installed}
  let(:test_bucket_name){"moment_display_spec_test"}
  let(:s3_conn){AWS::S3.new(keys.aws_hash)}
  let(:deployment){Moment::Deployment.new(test_bucket_name, keys)}
  before do
    s3_conn.buckets.create(test_bucket_name)
    # deployment.silent = false
    # repo = Rugged::Repository.new(GIT_REPO_DIR)
    # deployment.set_current_commit_id(repo.last_commit.oid)    
  end

  after do
    s3_conn.buckets[test_bucket_name].delete!
  end

  describe "deploying from a list of files", :vcr => vcr_current do

    let(:source){"spec/fixtures/files/site_dir_1"}
    let(:file_list){["index.html"]}
    it "should copy files to the service", :vcr => vcr_current do
      deployment.deploy_file_list(source, file_list)
      check_files_on_aws(test_bucket_name, file_list, source)
    end

    it "should overwrite eixsting files", :vcr => vcr_current do
      deployment.deploy_file_list(source, file_list)
      deployment.deploy_file_list("spec/fixtures/files/site_dir_2", file_list)
      check_files_on_aws(test_bucket_name, file_list, "spec/fixtures/files/site_dir_2")
    end
  end

  describe "deploy from a git repo", :vcr => vcr_current do

    let(:source){"site"}
    let(:dest_repo_dir){TEMP_DIR + "/git_test_repo"}

    after do
      deployment.temp_repo_cleanup(dest_repo_dir)
    end

    it "should copy files over from a local repo and set the commit id" do 
      source_repo_dir = GIT_REPO_DIR
      deployment.silent = true
      deployment.deploy_repo(source_repo_dir, :master, source, dest_repo_dir, false)

      local_path = File.expand_path(source, dest_repo_dir)
      files = Moment::Files.get_file_list local_path
      check_files_on_aws(test_bucket_name, files, local_path)
      deployment.get_current_commit_id.should_not be_nil
    end

    it "should only copy new files over from a local repo", {:vcr => vcr_dev} do
      # Copy the test repo and  deploy it fresh to AWS.
      source_repo_dir = GIT_REPO_DIR
      deployment.silent = true
      deployment.deploy_repo(source_repo_dir, :master, source, dest_repo_dir, false)
      orig_commit_id = deployment.get_current_commit_id

      # Add a new file to the local repo
      # - this should be fast and direct, if slightly opaque
      Dir.chdir(dest_repo_dir + "/site") do
        File.open("new_test.txt", 'w') {|f| f.puts "This is a new file."}
        system "git add new_test.txt"
        system "git commit --quiet -m 'Added a new file.'"
      end
      Dir.chdir(source_repo_dir) { system "git config receive.denyCurrentBranch ignore"}
      Dir.chdir(dest_repo_dir) {system "git push --quiet "}
      Dir.chdir(source_repo_dir) { system "git reset --quiet --hard" }

      # ... and remove the cloned repo
      FileUtils.rm_r(dest_repo_dir)

      # Delploy again to AWs, but this time don't make the local clone
      deployment.deploy_repo(source_repo_dir, :master, source, dest_repo_dir, false)

       # COMPARE THE FILES THAT ARE THERE WITH WHAT ARE SUPPOSED TO BE THERE
       # TODO: ENSURE THAT ONLY THE NEW FILES IS ACTUALLY SENT.
      local_path = File.expand_path(source, dest_repo_dir)
      files = Moment::Files.get_file_list local_path
      check_files_on_aws(test_bucket_name, files, local_path)
      deployment.get_current_commit_id.should_not eq orig_commit_id

      # Now return the test repo back to it's original state.
      Dir.chdir(source_repo_dir) { system "git reset #{orig_commit_id} --quiet --hard"}

    end


    # THIS IS EXPENSIVE IT GOES TO A GIT REPO ON GITHUB.
    it "should copy files over from a remote repo" do
      pending "This goes out on the net and clones a git repo. Put this in a CI"
      source_repo_dir = "ssh://git@bitbucket.org/jdrivas/moment_test_repo_1.git"
      deployment.deploy_repo(source_repo_dir, :master, source, dest_repo_dir, false)

      local_path = File.expand_path(source, dest_repo_dir)
      files = Moment::Files.get_file_list local_path
      check_files_on_aws(test_bucket_name, files, local_path)
      deployment.get_current_commit_id.should_not be_nil      
    end

  end
end