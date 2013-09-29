require 'fileutils'

# This was created for testing and factored out to use in multiple specs.
#
# This will visit a structure built from an Array of Strings and Hashes.
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
module Moment
  class FileTree
    attr_reader :files, :tree_root

    def initialize file_struct, root_dir_name=nil
      @files = file_struct
      @tree_root = root_dir_name || "."
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
        raise "Bad directory structure #{files}"
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
        raise "Bad directory structure #{files}"
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
              raise "BAD VISIT TREE TYPE. #{type}"
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
          raise "BAD VISIT TYREE TYPE. #{type}"
        end
      end
      file_list
    end

    def self.delete(root)
      FileUtils.rmtree root
    end

    # Speificaly for testing
    def self.verify_files(files, list, dir)
      ft = FileTree.new(files, dir)
      list == ft.file_list
    end


  end
end