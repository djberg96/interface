require_relative 'lib/interface'

TestInterface = interface {
  required_methods :foo, :bar
}

puts "Testing empty class with include at top..."

begin
  test_class = Class.new do
    include TestInterface
    # No methods defined
  end
  puts "No error raised - this indicates deferred validation didn't trigger"
rescue Interface::MethodMissing => e
  puts "Error caught: #{e.message}"
end
