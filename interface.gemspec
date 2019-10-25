require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'interface'
  spec.version    = '1.0.5'
  spec.author     = 'Daniel J. Berger'
  spec.license    = 'Artistic-2.0'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'http://github.com/djberg96/interface'
  spec.summary    = 'Java style interfaces for Ruby'
  spec.test_file  = 'test/test_interface.rb'
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.cert_chain = Dir['certs/*']

  spec.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']

  spec.add_development_dependency('test-unit')
  spec.add_development_dependency('rake')

  spec.metadata = {
    'homepage_uri'      => 'https://github.com/djberg96/interface',
    'bug_tracker_uri'   => 'https://github.com/djberg96/interface/issues',
    'changelog_uri'     => 'https://github.com/djberg96/interface/blob/master/CHANGES',
    'documentation_uri' => 'https://github.com/djberg96/interface/wiki',
    'source_code_uri'   => 'https://github.com/djberg96/interface',
    'wiki_uri'          => 'https://github.com/djberg96/interface/wiki'
  }

  spec.description = <<-EOF
    The interface library implements Java style interfaces for Ruby.
    It lets you define a set a methods that must be defined in the
    including class or module, or an error is raised.
  EOF
end
