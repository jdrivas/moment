module Moment
  class Git
    attr_accessor :repo

    def initialize(repo_name)
      @repo = repo_name
    end

    def clone(name, branch)
      system "git clone -b #{branch} #{self.repo} #{name}"
    end
  end
end