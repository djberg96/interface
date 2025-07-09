#######################################################################
# example_interface.rb
#
# Sample test script that demonstrates a typical interface. You can
# run this example via the 'rake example:interface' task. Modify this
# code as you see fit.
#######################################################################
require_relative '../lib/interface'

MyInterface = interface{
  required_methods :foo, :bar
}

class MyClass
  include MyInterface
  def foo; end
  def bar; end
end

=begin
# Raises an error until bar is defined
class Foo
  def foo
    puts "foo"
  end
  include MyInterface
end
=end
