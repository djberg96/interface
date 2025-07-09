require_relative 'lib/interface'

MyInterface = interface{
  required_methods :foo, :bar
}

class MyClass
  include MyInterface
  def foo; end
  def bar; end
end

# This should raise an error until bar is defined
class Foo
  include MyInterface
  def foo
    puts "foo"
  end
end
