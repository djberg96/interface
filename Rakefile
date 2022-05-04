require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'

CLEAN.include("**/*.gem", "**/*.rbc", "**/*.lock")

namespace :gem do
  desc "Create the interface gem"
  task :create => [:clean] do 
    require 'rubygems/package'
    spec = Gem::Specification.load('interface.gemspec')
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec)
  end

  desc "Install the interface gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

namespace :example do
  desc 'Run the example_instance.rb sample program'
  task :instance do
    ruby '-Ilib examples/example_instance.rb'
  end

  desc 'Run the example_interface.rb sample program'
  task :interface do
    ruby '-Ilib examples/example_interface.rb'
  end

  desc 'Run the example_sub.rb sample program'
  task :sub do
    ruby '-Ilib examples/example_sub.rb'
  end

  desc 'Run the example_unrequire.rb sample program'
  task :unrequire do
    ruby '-Ilib examples/example_unrequire.rb'
  end
end

desc "Run the test suite"
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
