require_relative 'lib/interface'

TestInterface = interface {
  required_methods :foo, :bar
}

puts "Testing include at top with all methods defined..."

class CompleteClass
  include TestInterface
  def foo; puts "foo method"; end
  def bar; puts "bar method"; end
end

puts "Success! Class with include at top works when all methods are defined."

# Test that the class actually works
obj = CompleteClass.new
obj.foo
obj.bar
