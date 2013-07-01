module Moment
  class Git
    attr accessor :repo

    def nitialize(repo_name)
      @repo = repo_name
    end

    def clone(dir)
      Dir.cwd("dir") do 
        system "git clone #{self.repo}"
      end
    end
  end
end