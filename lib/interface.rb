# frozen_string_literal: true

# A module for implementing Java style interfaces in Ruby. For more information
# about Java interfaces, please see:
#
# http://java.sun.com/docs/books/tutorial/java/concepts/interface.html
#
# @author Daniel J. Berger
# @since 1.0.0
module Interface
  # The version of the interface library.
  VERSION = '1.2.0'.freeze

  # Raised if a class or instance does not meet the interface requirements.
  # Provides detailed information about which methods are missing and from which target.
  class MethodMissing < RuntimeError
    # @return [Array<Symbol>] the missing method names
    attr_reader :missing_methods

    # @return [String] the name of the target class/module
    attr_reader :target_name

    # @return [String] the name of the interface
    attr_reader :interface_name

    # Creates a new MethodMissing error with detailed information
    #
    # @param missing_methods [Array<Symbol>, Symbol] the missing method name(s)
    # @param target [Module, Class] the target class or module
    # @param interface_mod [Module] the interface module
    def initialize(missing_methods, target = nil, interface_mod = nil)
      @missing_methods = Array(missing_methods)
      @target_name = target&.name || target&.class&.name || 'Unknown'
      @interface_name = interface_mod&.name || 'Unknown Interface'

      methods_list = @missing_methods.map { |m| "`#{m}`" }.join(', ')
      super("#{@target_name} must implement #{methods_list} to satisfy #{@interface_name}")
    end
  end

  alias extends extend

  private

  # Handles extending an object with the interface
  #
  # @param obj [Object] the object to extend
  # @return [Object] the extended object
  def extend_object(obj)
    return append_features(obj) if obj.is_a?(Interface)
    append_features(obj.singleton_class)
    included(obj)
  end

  # Validates interface requirements when included/extended
  #
  # @param mod [Module] the module being extended
  # @return [Module] the module
  # @raise [Interface::MethodMissing] if required methods are not implemented
  def append_features(mod)
    return super if mod.is_a?(Interface)

    # For extend on instances or immediate validation
    if should_validate_immediately?(mod)
      validate_interface_requirements(mod)
    end
    super
  end

  # Called when this interface is included in a class or module
  #
  # @param base [Class, Module] the class or module that included this interface
  def included(base)
    super
    return if base.is_a?(Interface)

    interface_module = self
    
    # For classes, set up method tracking to validate after all methods are defined
    if base.is_a?(Class)
      # Store reference to interface for later validation
      base.instance_variable_set(:@pending_interface_validations, 
        (base.instance_variable_get(:@pending_interface_validations) || []) + [interface_module])
      
      # Set up method_added callback if not already done
      unless base.respond_to?(:interface_method_added_original)
        base.singleton_class.alias_method(:interface_method_added_original, :method_added) if base.respond_to?(:method_added)
        
        base.define_singleton_method(:method_added) do |method_name|
          # Call original method_added if it existed
          interface_method_added_original(method_name) if respond_to?(:interface_method_added_original)
          
          # Check if all pending interfaces are now satisfied
          pending = instance_variable_get(:@pending_interface_validations) || []
          pending.each do |interface_mod|
            if interface_mod.satisfied_by?(self)
              # Interface is satisfied, remove from pending
              pending.delete(interface_mod)
            end
          end
          instance_variable_set(:@pending_interface_validations, pending)
        end
        
        # Set up validation at class end using TracePoint
        setup_deferred_validation(base)
      end
    else
      # For modules and instances, validate immediately
      validate_interface_requirements(base)
    end
  end

  # Determines if we should validate immediately or defer validation
  #
  # @param mod [Module] the module to check
  # @return [Boolean] true if validation should happen immediately
  def should_validate_immediately?(mod)
    required_method_ids = compute_required_methods
    return true if required_method_ids.empty?

    # Always validate immediately for instances (singleton classes)
    return true if mod.singleton_class?

    # Check if any required methods are already defined
    implemented_methods = get_implemented_methods(mod)
    (required_method_ids & implemented_methods).any?
  rescue NoMethodError
    # If instance_methods fails, this is likely an instance, validate immediately
    true
  end

  # Sets up deferred validation using TracePoint to detect when class definition ends
  #
  # @param base [Class, Module] the class or module to validate later
  def setup_deferred_validation(base)
    interface_module = self
    
    # Use TracePoint to detect when we're done defining the class
    trace = TracePoint.new(:end) do |tp|
      # Check if we're ending the definition of our target class
      if tp.self == base
        trace.disable
        
        # Validate any remaining pending interfaces
        pending = base.instance_variable_get(:@pending_interface_validations) || []
        pending.each do |interface_mod|
          begin
            interface_mod.send(:validate_interface_requirements, base)
          rescue => e
            raise e
          end
        end
      end
    end
    
    trace.enable
  end

  # Validates that all required methods are implemented
  #
  # @param mod [Module] the module to validate
  # @raise [Interface::MethodMissing] if required methods are missing
  def validate_interface_requirements(mod)
    required_method_ids = compute_required_methods
    implemented_methods = get_implemented_methods(mod)
    missing_methods = required_method_ids - implemented_methods

    return if missing_methods.empty?

    # For backward compatibility, raise with first missing method if only one
    # Otherwise use the enhanced error with full details
    if missing_methods.size == 1
      raise Interface::MethodMissing.new(missing_methods.first, mod, self)
    else
      raise Interface::MethodMissing.new(missing_methods, mod, self)
    end
  end

  # Computes the final list of required methods after inheritance and unrequired methods
  #
  # @return [Array<Symbol>] the required method symbols
  def compute_required_methods
    inherited_methods = compute_inherited_methods
    all_required = ((@ids || []) + inherited_methods).uniq
    all_required - (@unreq || [])
  end

  # Gets inherited method requirements from parent interfaces
  #
  # @return [Array<Symbol>] inherited required methods
  def compute_inherited_methods
    parent_interfaces = ancestors.drop(1).select { |ancestor| ancestor.is_a?(Interface) }
    parent_interfaces.flat_map { |interface| interface.instance_variable_get(:@ids) || [] }
  end

  # Gets the list of implemented methods for a module
  #
  # @param mod [Module] the module to check
  # @return [Array<Symbol>] implemented method names
  def get_implemented_methods(mod)
    if mod.respond_to?(:instance_methods)
      mod.instance_methods(true)
    else
      # For instances, get methods from their singleton class
      mod.methods.map(&:to_sym)
    end
  end

  public

  # Accepts an array of method names that define the interface. When this
  # module is included/implemented, those method names must have already been
  # defined.
  #
  # @param method_names [Array<Symbol>] method names that must be implemented
  # @return [Array<Symbol>] the updated list of required methods
  # @raise [ArgumentError] if no method names are provided
  # @example
  #   MyInterface = interface do
  #     required_methods :foo, :bar, :baz
  #   end
  def required_methods(*method_names)
    raise ArgumentError, 'At least one method name must be provided' if method_names.empty?

    @ids = method_names.map(&:to_sym)
  end

  # Accepts an array of method names that are removed as a requirement for
  # implementation. Presumably you would use this in a sub-interface where
  # you only wanted a partial implementation of an existing interface.
  #
  # @param method_names [Array<Symbol>] method names to remove from requirements
  # @return [Array<Symbol>] the updated list of unrequired methods
  # @example
  #   SubInterface = interface do
  #     extends ParentInterface
  #     unrequired_methods :optional_method
  #   end
  def unrequired_methods(*method_names)
    @unreq ||= []
    return @unreq if method_names.empty?

    @unreq += method_names.map(&:to_sym)
  end

  # Returns the list of all required methods for this interface
  #
  # @return [Array<Symbol>] all required method names
  def get_required_methods
    compute_required_methods
  end

  # Returns the list of unrequired methods for this interface
  #
  # @return [Array<Symbol>] unrequired method names
  def get_unrequired_methods
    (@unreq || []).dup
  end

  # Checks if a class or module implements this interface
  #
  # @param target [Class, Module] the class or module to check
  # @return [Boolean] true if the interface is satisfied
  def satisfied_by?(target)
    required_method_ids = compute_required_methods
    implemented_methods = get_implemented_methods(target)
    (required_method_ids - implemented_methods).empty?
  end
end

# Extends Object to provide the interface method for creating interfaces
class Object
  # The interface method creates an interface module which typically sets
  # a list of methods that must be defined in the including class or module.
  # If the methods are not defined, an Interface::MethodMissing error is raised.
  #
  # An interface can extend an existing interface as well. These are called
  # sub-interfaces, and they can include the rules for their parent interface
  # by simply extending it.
  #
  # @yield [Module] the interface module for configuration
  # @return [Module] a new interface module
  # @raise [ArgumentError] if no block is provided
  #
  # @example Basic interface
  #   # Require 'alpha' and 'beta' methods
  #   AlphaInterface = interface do
  #     required_methods :alpha, :beta
  #   end
  #
  # @example Sub-interface
  #   # A sub-interface that requires 'beta' and 'gamma' only
  #   GammaInterface = interface do
  #     extends AlphaInterface
  #     required_methods :gamma
  #     unrequired_methods :alpha
  #   end
  #
  # @example Usage with error
  #   # Raises an Interface::MethodMissing error because :beta is not defined.
  #   class MyClass
  #     def alpha
  #       # ...
  #     end
  #     implements AlphaInterface
  #   end
  def interface(&block)
    raise ArgumentError, 'Block required for interface definition' unless block_given?

    Module.new do |mod|
      mod.extend(Interface)
      mod.instance_eval(&block)
    end
  end
end

# Extends Module to provide the implements method as an alias for include
class Module
  # Implements an interface by including it. This is syntactic sugar
  # that makes the intent clearer when working with interfaces.
  #
  # @param interface_modules [Array<Module>] one or more interface modules
  # @return [self]
  #
  # @example
  #   class MyClass
  #     def required_method
  #       # implementation
  #     end
  #
  #     implements MyInterface
  #   end
  alias implements include
end
