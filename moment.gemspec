# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','moment','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'moment'
  s.version = Moment::VERSION
  s.author = 'Your Name Here'
  s.email = 'your@email.address.com'
  s.homepage = 'http://your.website.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A description of your project'
# Add your other files here if you make them
  s.files = %w(
bin/moment
lib/moment/version.rb
lib/moment/keys.rb
lib/moment.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','moment.rdoc']
  s.rdoc_options << '--title' << 'moment' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'moment'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_development_dependency('rspec')  
  s.add_development_dependency('guard')
  s.add_development_dependency('rb-fsevent')
  s.add_development_dependency('guard-cucumber')  
  s.add_development_dependency('guard-rspec')
  s.add_development_dependency('webmock')
  s.add_development_dependency('vcr')
  s.add_runtime_dependency('gli','2.5.6')
  s.add_runtime_dependency('aws-sdk', '~>1.0')  
  s.add_runtime_dependency('highline')  
end
