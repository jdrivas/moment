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
				files.each {|f| puts "- #{File.expand_path(f, source)} => #{endpoint}: #{f}"}
				puts "Using Template Engine: #{template_engine.name}"
			end

			unless dry_run
				build(source)
				put_files(source, files, endpoint)
				# cleanup
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

		# def cleanup
		# end

		# Let branch be either a string or symbol (or anything else that to_s works on)
		def deploy_repo(repo, branch, source, repo_clone_directory, repo_cleanup = true)
			puts "Cloning repo: \"#{repo}\", branch: \"#{branch}\" into #{repo_clone_directory}" unless silent
			unless dry_run
				source = File.expand_path(source, repo_clone_directory)
				git = Moment::Git.new(repo)
				git.silent = silent
				git.clone(repo_clone_directory, branch.to_s)
			end
			deploy_file_list(source, Moment::Files.get_file_list(source))
			temp_repo_cleanup(repo_clone_directory) if repo_cleanup
		end

		def temp_repo_cleanup (dir)
	    FileUtils.rm_rf dir if File.exist?(dir) unless dry_run
		end

	end

end