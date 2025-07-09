require_relative 'lib/interface'

TestInterface = interface {
  required_methods :foo, :bar
}

puts "Testing traditional include at bottom..."

class TraditionalClass
  def foo; puts "foo method"; end
  def bar; puts "bar method"; end
  include TestInterface
end

puts "Success! Traditional include at bottom still works."

# Test that the class actually works
obj = TraditionalClass.new
obj.foo
obj.bar
