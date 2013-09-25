module Moment
  GIT_TEMP_CLONE = "/tmp/moment.git.clone"
  class Git
    attr_accessor :repo
    attr_accessor :silent

    def initialize(repo_name)
      @repo = repo_name
      @silent = true
    end

    def clone(name, branch)
      command = "git clone " + (@silent ? "--quiet" : '') + " -b #{branch} #{self.repo} #{name}"
      system command
    end
  end
end