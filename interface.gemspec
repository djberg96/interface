require 'rubygems'

Gem::Specification.new do |spec|
  spec.name      = 'interface'
  spec.version   = '1.0.3'
  spec.author    = 'Daniel J. Berger'
  spec.license   = 'Artistic 2.0'
  spec.email     = 'djberg96@gmail.com'
  spec.homepage  = 'https://github.com/djberg96/interface'
  spec.summary   = 'Java style interfaces for Ruby'
  spec.test_file = 'test/test_interface.rb'
  spec.files     = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']

  spec.add_development_dependency('test-unit')
  spec.add_development_dependency('rake')

  spec.description = <<-EOF
    The interface library implements Java style interfaces for Ruby.
    It lets you define a set a methods that must be defined in the
    including class or module, or an error is raised.
  EOF
end
