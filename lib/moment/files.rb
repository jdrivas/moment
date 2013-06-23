module Moment
  class Files

    def self.get_file_list(directory_name)
      files = []
      Dir.chdir(directory_name) do
        files = get_files(".")
      end
      files.each {|f| f.gsub!(/^\.\//,"")}  # remove any leading ./
    end

    def self.get_files(dir)
      files = []
      Dir.foreach(dir) do |file|
        next if file.match(/\.{1,2}$/)  # ignore '.' and '..'
        path = dir + "/" + file.gsub(/^\.\//,"") # remove a leading ./
        if File.directory?(path)
          files += get_files(path)
        else
          files.push(path)
        end
      end
      files
    end
  end
end
