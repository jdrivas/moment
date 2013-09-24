module Moment

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
				files.each {|f| puts "- #{File.expand_path(f, self.source)} => #{endpoint}: #{f}"}
				puts "Using Template Engine: #{template_engine.name}"
			end

			unless dry_run
				build(source)
				put_files(source, files,endpoint)
				cleanup
			end

		end

		def deploy_repo(repo, branch, repo_clone_directory = Moment::GIT_TEMP_CLONE)
			puts "Cloning: #{repo} into #{repo_clone_directory}" unless silent
			source = repo_clone_directory
			git = Moment::Git.new(repo)
			git.clone(source, branch)
			deploy_file_list(source, Moment::Files.get_file_list(source))
		end

		def build(source)
			puts "building .... " unless silent
			template_engine.build(source)
		end

		def put_files(source, files, endpoint)
			service = Moment::S3.new(credentials)
			service.put_files(endpoint, source, files)
		end

		def cleanup
		end

	end

end