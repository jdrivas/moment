require 'spec_helper'
require 'moment'

TEST_DIR_NAME = "test_dir"

def test_file_build files
  ft = Moment::FileTree.new(files, TEST_DIR_NAME)
  ft.build_tree
  File.directory?(TEST_DIR_NAME).should be_true
  Dir.chdir(TEST_DIR_NAME) {yield if block_given?}
end

# TODO: make fakefs work with this.
describe "files test code", :fakefs do

  before {Dir.mkdir(TEST_DIR_NAME)}

  describe "build_files" do

    after {Moment::FileTree.delete TEST_DIR_NAME}

    describe "with one file" do
      let(:files){['tfile']}
      let(:file_list){["#{TEST_DIR_NAME}/tfile"]}
      it "should create a directory with a single file" do
        test_file_build files {files.each {|f|  File.exist?(f).should be_true}}
       end

       it "should create a file list with a single file" do
        Moment::FileTree.verify_files(files, file_list, TEST_DIR_NAME).should be_true
       end
    end

    describe "with two files" do
      let(:files){["file_1", "file_2"]}
      let(:file_list){["#{TEST_DIR_NAME}/file_1", "#{TEST_DIR_NAME}/file_2"]}
      it "should create a directory witha single file" do
        test_file_build files {files.each {|f| File.exist?(f).should be_true}}
      end

      it "should create a file list with two files" do
        Moment::FileTree.verify_files(files, file_list, TEST_DIR_NAME).should be_true
      end
    end

    describe "with a single empty sub directory" do
      let(:files){[{"Dir" => []}]}
      it "should create a directory with a single sub directory" do
        test_file_build files do
          File.directory?("Dir").should be_true
        end
      end
    end

    describe "with a single empty directory and an single file" do
      let(:files){['top_file', {"Dir1" => []}]}
      it "should create a single file and an emtpy directory" do
        test_file_build files do
          File.directory?("Dir1").should be_true
          File.exist?("top_file").should be_true
        end
      end
    end

    describe "nested directories" do
      let(:files){[{"TopDir" => ["down_1", {"NestedDir" => ["down_2"]}]}]}
      it "should create nested directories with files in them" do
        test_file_build files do
          File.directory?("TopDir").should be_true
          File.exist?("TopDir/down_1").should be_true
          File.directory?("TopDir/NestedDir").should be_true
          File.exist?("TopDir/NestedDir/down_2").should be_true
        end
      end
    end
  end
end