require_relative 'lib/interface'

puts "=== Demonstrating include at top of class ==="
puts

# Define an interface
PaymentInterface = interface do
  required_methods :process_payment, :validate_card
end

puts "1. ✅ Success case - include at top with all methods defined:"
class CreditCardProcessor
  include PaymentInterface  # ← This now works at the top!
  
  def process_payment
    puts "Processing credit card payment..."
  end
  
  def validate_card
    puts "Validating credit card..."
  end
end

processor = CreditCardProcessor.new
processor.validate_card
processor.process_payment

puts

puts "2. ❌ Error case - include at top with missing method:"
begin
  class IncompleteProcessor
    include PaymentInterface  # ← Include at top
    
    def process_payment
      puts "Processing payment..."
    end
    # Missing validate_card method!
  end
rescue Interface::MethodMissing => e
  puts "Caught error: #{e.message}"
end

puts

puts "3. ✅ Traditional approach still works:"
class TraditionalProcessor
  def process_payment
    puts "Processing payment..."
  end
  
  def validate_card
    puts "Validating card..."
  end
  
  include PaymentInterface  # ← Include at bottom still works
end

traditional = TraditionalProcessor.new
traditional.validate_card
traditional.process_payment

puts
puts "=== All functionality working! ==="
