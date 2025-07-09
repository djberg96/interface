# frozen_string_literal: true

require_relative '../lib/interface'

puts "=== Interface Library Improvements Demo ==="
puts

# 1. Enhanced Error Messages
puts "1. Enhanced Error Messages:"
puts "-" * 40

PaymentInterface = interface do
  required_methods :process_payment, :validate_payment, :send_receipt
end

class IncompletePaymentProcessor
  def process_payment
    puts "Processing payment..."
  end
  # Missing validate_payment and send_receipt methods
end

begin
  IncompletePaymentProcessor.include PaymentInterface
rescue Interface::MethodMissing => e
  puts "Error caught with enhanced details:"
  puts "  Missing methods: #{e.missing_methods.join(', ')}"
  puts "  Target class: #{e.target_name}"
  puts "  Interface: #{e.interface_name}"
  puts "  Full message: #{e.message}"
end

puts

# 2. Interface Introspection
puts "2. Interface Introspection:"
puts "-" * 40

StorageInterface = interface do
  required_methods :save, :load, :delete
end

puts "Required methods: #{StorageInterface.get_required_methods}"

# 3. Sub-interface with unrequired methods
puts "3. Sub-interface with selective requirements:"
puts "-" * 40

ReadOnlyStorageInterface = interface do
  extend StorageInterface
  unrequired_methods :save, :delete
end

puts "Original interface requires: #{StorageInterface.get_required_methods}"
puts "Read-only interface requires: #{ReadOnlyStorageInterface.get_required_methods}"
puts "Read-only interface unrequires: #{ReadOnlyStorageInterface.get_unrequired_methods}"

# 4. Interface Satisfaction Checking
puts "4. Interface Satisfaction Checking:"
puts "-" * 40

class FileStorage
  def save; puts "Saving to file"; end
  def load; puts "Loading from file"; end
  def delete; puts "Deleting file"; end
end

class ReadOnlyFileStorage
  def load; puts "Loading from file"; end
end

puts "FileStorage satisfies StorageInterface: #{StorageInterface.satisfied_by?(FileStorage)}"
puts "ReadOnlyFileStorage satisfies StorageInterface: #{StorageInterface.satisfied_by?(ReadOnlyFileStorage)}"
puts "ReadOnlyFileStorage satisfies ReadOnlyStorageInterface: #{ReadOnlyStorageInterface.satisfied_by?(ReadOnlyFileStorage)}"

# 5. Complex inheritance hierarchy
puts "5. Complex Interface Inheritance:"
puts "-" * 40

BaseInterface = interface do
  required_methods :initialize_connection, :close_connection
end

AuthenticatedInterface = interface do
  extend BaseInterface
  required_methods :authenticate, :authorize
end

DatabaseInterface = interface do
  extend AuthenticatedInterface
  required_methods :query, :transaction
  unrequired_methods :authorize  # Don't require authorization for this specific interface
end

puts "BaseInterface requires: #{BaseInterface.get_required_methods}"
puts "AuthenticatedInterface requires: #{AuthenticatedInterface.get_required_methods}"
puts "DatabaseInterface requires: #{DatabaseInterface.get_required_methods}"

# 6. String to symbol conversion
puts "6. Automatic String to Symbol Conversion:"
puts "-" * 40

StringInterface = interface do
  required_methods 'string_method', 'another_string_method'
end

puts "Methods defined with strings: #{StringInterface.get_required_methods}"

puts
puts "=== Demo Complete ==="
