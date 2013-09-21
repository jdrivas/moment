module Moment

	class Deploy
		attr_accessor :source, :files, :endpoint, :template_engine, :credentials
		attr_accessor :dry_run, :silent


		def initialize(deploy_source, deploy_files, deploy_endpoint, deploy_credentials)
			@source = deploy_source
			@files = deploy_files
			@endpoint = deploy_endpoint
			@credentials = deploy_credentials
			@template_engine = Moment::TemplateEngine.get_engine
			@dry_run = false
			@silent = true
			@use_network = true
		end

		def deploy

			unless silent
				puts "Update endpoint: Amazon S3 bucket \"#{endpoint}\"."
				puts "From source: \"#{source}\"."
				puts "Updates are: "
				files.each {|f| puts "- #{File.expand_path(f, self.source)} => #{endpoint}: #{f}"}
				puts "Using Template Engine: #{template_engine.name}"
			end	

			unless dry_run
				build
				deploy_files
				cleanup
			end

		end

		def build
			puts "building .... " unless silent
			template_engine.build(source)
		end

		def deploy_files
			service = Moment::S3.new(credentials)
			service.put_files(endpoint, source, files)
		end

		def cleanup
		end

	end

end