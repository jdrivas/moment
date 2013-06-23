require 'spec_helper'
require 'moment'
require 'fileutils'


# This will visit a structure build from an Array of Strings and Hashes.
# The hashes will have a String key and an Array of Strings and Hashes
# just like the top Array.
#
# The top_level array is a directory contents.
# Each string in the array represents a file name.
# A Hash key is a String which represents a directory_name 
# the value is and Array which is the contents of the directory.
#
# ["top_level_file", 
#   {"Dir1" => ["level_2_file", 
#               {"Dir2"} => ["level_3 file"]
#              ]
#   }
# ]
# 
# visit_tree visits each element and executes the block on it.
# Block gets two variables: type, name
# 
# Type is one of: :file, :directory
# Name is a string which is the name of the file or directory.
class FileTree
  attr_reader :files, :tree_root

  def initialize file_struct, root_dir_name=nil
    @files = file_struct
    @tree_root = root_dir_name
  end

  # Visit a directory heirarch specified by files.
  # TODO: This is broken, the chdir should be removed.
  # At least there should be a way to implement this with
  # visit_entries
  def visit_tree(files, &block)
    case files
    when Array
      files.each { | f| visit_tree(f,&block)}
    when String
      yield(:file, files) if block_given?
    when Hash
      files.each do |k,v|
        yield(:directory, k) if block_given?
        Dir.chdir(k) {visit_tree(v, &block) }
      end
    else
      throw "Bad directory structure #{files}"
    end
  end

  # Visit all entries 
  def visit_entries(files, &block)
    case files
    when Array
      files.each {|f| visit_entries(f, &block)} 
    when Hash 
      files.each {|k,v| yield(:directory, k) if block_given?}
    when String
      yield(:file, files) if block_given?
    else
      throw "Bad directory structure #{files}"
    end
  end

  # Build out a file heirarchy for this FileTree
  def build_tree tree_root=nil
    tree_root ||= self.tree_root
    Dir.mkdir(tree_root) unless File.directory?(tree_root)
    Dir.chdir(tree_root) do
      self.files.each do |entry|
        visit_tree entry do |type, name|
          case type
          when :file
            FileUtils.touch(name)
          when :directory
            Dir.mkdir(name)
          else
            throw "BAD VISIT TREE TYPE. #{type}"
          end
        end
      end
    end
  end

  def delete_tree
  end

  # Produce an array of all the pathnames to all of the files in the list.
  def file_list tree_root=nil
    tree_root ||= self.tree_root
    file_list = []
    current_dir =  tree_root
    visit_entries self.files do |type, name|
      case type
      when :directory
        current_dir = current_dir + "/" + name
      when :file
        file_list.push(current_dir + "/" + name)
      else
        throw "BAD VISIT TYREE TYPE. #{type}"
      end
    end
    file_list
  end

end

TEST_DIR_NAME = "tmp/test_dir"
def verify_files files, list
  ft = FileTree.new(files, TEST_DIR_NAME)
  list == ft.file_list
end

def rm_files files, tree_root = TEST_DIR_NAME
  FileUtils.rmtree tree_root
end

def test_file_build files
  ft = FileTree.new(files, TEST_DIR_NAME)
  ft.build_tree
  File.directory?(TEST_DIR_NAME).should be_true
  Dir.chdir(TEST_DIR_NAME) {yield if block_given?}
end

describe "files test code" do

  describe "build_files" do

    after {rm_files :files}

    describe "with one file" do
      let(:files){['tfile']}
      let(:file_list){["#{TEST_DIR_NAME}/tfile"]}
      it "should create a directory with a single file" do
        test_file_build files {files.each {|f|  File.exist?(f).should be_true}}
       end

       it "should create a file list with a single file" do
        verify_files(files, file_list).should be_true
       end
    end

    describe "with two files" do
      let(:files){["file_1", "file_2"]}
      let(:file_list){["#{TEST_DIR_NAME}/file_1", "#{TEST_DIR_NAME}/file_2"]}
      it "should create a directory witha single file" do
        test_file_build files {files.each {|f| File.exist?(f).should be_true}}
      end

      it "should create a file list with two files" do
        verify_files(files, file_list).should be_true
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

describe Moment::Files do 

  before {FileTree.new(files, TEST_DIR_NAME).build_tree}
  after {rm_files files}

  let(:file_list){Moment::Files.get_file_list(TEST_DIR_NAME)}

  describe "with one file" do

    let(:files) {['file']}

    it "should get a collection of files paths within a directory" do
      verify_files(files, file_list)
    end
  end

  describe "with two files" do
    let(:files){['file_1', 'file_2']}
    it "should find both files." do
      verify_files(files, file_list)
    end
  end

  describe "with one level of directory heirarchy" do
    let(:files){['top_file', {"Dir1" => ['nested_file']}]}
    it "should find files in a nested directories." do
      verify_files(files, file_list)
    end
  end

  describe "nested directories" do
    let(:files){[{"TopDir" => ["down_1", {"NestedDir" => ["down_2"]}]}]}
    it "should find files that in two levels of nesting" do
      verify_files(files, file_list)
    end
  end
end