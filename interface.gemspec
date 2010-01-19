require 'rubygems'

Gem::Specification.new do |spec|
  spec.name      = 'interface'
  spec.version   = '1.0.3'
  spec.author    = 'Daniel J. Berger'
  spec.license   = 'Artistic 2.0'
  spec.email     = 'djberg96@gmail.com'
  spec.homepage  = 'http://www.rubyforge.org/projects/shards'
  spec.summary   = 'Java style interfaces for Ruby'
  spec.test_file = 'test/test_interface.rb'
  spec.has_rdoc  = true
  spec.files     = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']
  spec.rubyforge_project = 'shards'

  spec.add_development_dependency('test-unit', '>= 2.0.3')

  spec.description = <<-EOF
    The interface library implements Java style interfaces for Ruby.
    It lets you define a set a methods that must be defined in the
    including class or module, or an error is raised.
  EOF
end
