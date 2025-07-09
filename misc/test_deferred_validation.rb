require_relative 'lib/interface'

TestInterface = interface {
  required_methods :foo, :bar
}

puts "Testing include at top with missing methods..."

class IncompleteClass
  include TestInterface
  def foo; puts "foo method"; end
  # Missing bar method
end

puts "This line should not be reached if validation works"
