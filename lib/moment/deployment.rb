require 'rugged'

module Moment

	CURRENT_COMMIT_FILE = ".commit_stamp"

	class Deployment
		attr_accessor :endpoint, :template_engine, :credentials
		attr_accessor :dry_run, :silent

		def initialize(deploy_endpoint, deploy_credentials, template_engine = nil)
			@endpoint = deploy_endpoint
			@credentials = deploy_credentials
			@template_engine = template_engine.nil? ? Moment::NoTemplate : template_engine
			@dry_run = false
			@silent = true
			@use_network = true
		end

		def deploy_file_list(source, files)

			unless silent
				puts "Update endpoint: Amazon S3 bucket \"#{endpoint}\"."
				puts "From source: \"#{source}\"."
				puts "Updates are: "
				files.each {|f| puts "- #{File.expand_path(f, source)} => #{endpoint}: #{f}"}
				puts "Using Template Engine: #{template_engine.name}"
			end

			unless dry_run
				build(source)
				put_files(source, files, endpoint)
			end

		end

		def build(source)
			puts "building .... " unless silent
			template_engine.build(source)
		end

		def put_files(source, files, endpoint)
			service = Moment::S3.new(credentials)
			service.put_files(endpoint, source, files)
		end

		# Let branch be either a string or symbol (or anything else that to_s works on)
		def deploy_repo(repo_url, branch, source, repo_clone_directory, repo_cleanup = true)

			puts "Deploying repo: \"#{repo_url}\", branch: \"#{branch}\" though #{repo_clone_directory} to #{endpoint}" unless silent
      
      return if dry_run

      create_local_clone(repo_url, branch, repo_clone_directory)

			##
			# TODO: What happens if we get hosed in the middle.
			# We need a way to reset to the latest commit (or even one before)
			##

			old_commit_id = get_current_commit_id
			if old_commit_id.nil? 
				puts "Didn't find a commit id at the endpoint." unless silent
			else 
				puts "Commit on endpoint is: #{old_commit_id}" unless silent
			end

      local_repo = Rugged::Repository.new(repo_clone_directory)  

			last_commit_id = local_repo.last_commit.oid
			set_current_commit_id(last_commit_id)

      # TODO: Implement update_endpoint!
			deltas = local_repo.diff(old_commit_id, last_commit_id).deltas
			update_endpoint(deltas)

      source = File.expand_path(source, repo_clone_directory)
			deploy_file_list(source, Moment::Files.get_file_list(source))

			temp_repo_cleanup(repo_clone_directory) if repo_cleanup
		end

    def create_local_clone(source_url, branch, clone_directory)
      git = Moment::Git.new(source_url)
      git.silent = silent
      git.clone(clone_directory, branch.to_s)
    end

		def temp_repo_cleanup (dir)
	    FileUtils.rm_rf dir if File.exist?(dir) unless dry_run
		end

		def get_current_commit_id
			Moment::S3.new(credentials).get_data(endpoint, CURRENT_COMMIT_FILE)
		end

		def set_current_commit_id(id)
			Moment::S3.new(credentials).put_data(endpoint, CURRENT_COMMIT_FILE, id)
		end

		def update_endpoint(deltas)
			unless silent
				puts "There are #{deltas.size} update."
				if old_commit_id.nil?
					puts "first commit."
				else
					puts "old: #{old_commit_id}, new: #{last_commit_id}"
				end
				puts "Update list is:"
				deltas.each do |d|
					puts "#{d.old_file[:path]} => #{d.new_file[:path]} : #{d.status}"
				end
			end
			deltas.each do |delta|
				update_endpoint_with_delta(delta)
			end

		end

		def update_endpoint_with_delta(delta)
			put_files = []
			remove_files = []
			case delta.status
			when :added
				put_files << delta.old_file[:path]
			when :deleted
				remove_files << delta.old_file[:path]
			when :modified
				put_files << delta.old_file[:path]
			when :renamed
				put_files << delta.new_file[:path]
				remove_files << delta.old_file[:path]
			when :copied
				put_files << delta.new_file[:path]
			when :ignored
			when :untracked
				remove_files << delta.old_file[:path]
			when :typechange?
			end

			copy_files(put_files)
			delete_files(remove_files)
		end

		def copy_files(files)
		end

		def delete_files(files)
		end
		
	end

			# Delete files marked for deletion
			# Move files marked for move
			# Update files marked for updating.
			 # class Delta
    #   attr_reader :owner
    #   alias diff owner

    #   attr_reader :old_file
    #   attr_reader :new_file
    #   attr_reader :similarity
    #   attr_reader :status
    #   attr_reader :binary

    #   alias binary? binary

    #   def added?
    #     status == :added
    #   end

    #   def deleted?
    #     status == :deleted
    #   end

    #   def modified?
    #     status == :modified
    #   end

    #   def renamed?
    #     status == :renamed
    #   end

    #   def copied?
    #     status == :copied
    #   end

    #   def ignored?
    #     status == :ignored
    #   end

    #   def untracked?
    #     status == :untracked
    #   end

    #   def typechange?
    #     status == :typechange
    #   end


	# 
	# Originally from the moment command line app.
	# 
  #   files = [] 
  #   temp_repo_clone = Moment::GIT_TEMP_CLONE
  #   if options[:git] 
  #     repo = environment[:repo]
  #     raise GLI::BadCommandLine.new("No source git repo.") if repo.nil?

  #     branch = environment[:branch] || args[0]
  #     source = File.expand_path(global_options[:directory], temp_repo_clone)
  #     unless options[:no_network]
  #       puts "Cloning: #{repo} into #{temp_repo_clone}"
  #       git = Moment::Git.new(repo)
  #       git.clone(temp_repo_clone, branch)

  #       # TODO: Add a current_commit.txt file with the current commit

  #       # TODO: Build a list of changed files from the previous commit and the current one.

  #       # TODO: create the files list only from an updated list
  #       # probably want a flag that allows you to update all.
  #       files = Moment::Files.get_file_list source
  #     end
  #   else
  #     source = File.expand_path global_options[:directory]
  #     files = Moment::Files.get_file_list source
  #   end

  #   if options[:dry_run]
  #     puts "Update endpoint: Amazon S3 bucket \"#{endpoint}\"."
  #     puts "From source: \"#{source}\"."
  #     puts (options[:git] ?  "Git repo to use: #{repo} with branch #{branch}" : "Updates are:" )
  #     files.each { |f| puts "- #{File.expand_path(f,source)} -> #{endpoint}: #{f}" }
  #   else
  #     puts "looking for template engine: #{global_options[:template_type]}." 
  #     template_engine = Moment::TemplateEngine.get_engine
  #     puts "building with: #{template_engine.name}"
  #     template_engine.build(source)
  #     unless options[:no_network]
  #       credentials = Moment::Keys.installed
  #       static_service = Moment::S3.new(credentials)
  #       static_service.put_files(endpoint, source, files)
  #     end
  #     # FileUtils.rm_rf temp_repo_clone if File.exist?(temp_repo_clone)
  #   end

end