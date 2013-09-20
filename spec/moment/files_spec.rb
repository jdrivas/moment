require 'spec_helper'
require 'moment'


TEST_DIR_NAME = "test_dir"

describe Moment::Files, :fakefs do 

  before {Moment::FileTree.new(files, TEST_DIR_NAME).build_tree}

  after{Moment::FileTree.delete TEST_DIR_NAME}

  let(:file_list){Moment::Files.get_file_list(TEST_DIR_NAME)}

  describe "with one file" do

    let(:files) {['file']}

    it "should get a collection of files paths within a directory" do
      Moment::FileTree.verify_files(files, file_list, TEST_DIR_NAME)
    end
  end

  describe "with two files" do
    let(:files){['file_1', 'file_2']}
    it "should find both files." do
      Moment::FileTree.verify_files(files, file_list, TEST_DIR_NAME)
    end
  end

  describe "with one level of directory heirarchy" do
    let(:files){['top_file', {"Dir1" => ['nested_file']}]}
    it "should find files in a nested directories." do
      Moment::FileTree.verify_files(files, file_list, TEST_DIR_NAME)
    end
  end

  describe "nested directories" do
    let(:files){[{"TopDir" => ["down_1", {"NestedDir" => ["down_2"]}]}]}
    it "should find files that in two levels of nesting" do
      Moment::FileTree.verify_files(files, file_list, TEST_DIR_NAME)
    end
  end
end