# frozen_string_literal: true

require 'rspec'
require 'interface'

RSpec.describe 'Interface Enhanced Features' do
  describe 'enhanced error messages' do
    it 'provides detailed error information for single missing method' do
      basic_interface = interface do
        required_methods :method_a, :method_b
      end

      # Use a block to ensure the error happens synchronously
      expect do
        Class.new do
          def method_a; end
          # missing method_b
          include basic_interface
        end
      end.to raise_error(Interface::MethodMissing) do |error|
        expect(error.missing_methods).to include(:method_b)
        expect(error.message).to include('must implement')
      end
    end

    it 'supports include at top of class definition' do
      basic_interface = interface do
        required_methods :method_a, :method_b
      end

      # Test the main functionality - include at top with working methods
      test_class = Class.new do
        include basic_interface
        def method_a; 'a'; end
        def method_b; 'b'; end
      end

      expect(test_class.new.method_a).to eq('a')
      expect(test_class.new.method_b).to eq('b')
    end
  end

  describe 'interface validation methods' do
    it 'returns required methods list' do
      basic_interface = interface do
        required_methods :method_a, :method_b
      end
      
      expect(basic_interface.get_required_methods).to contain_exactly(:method_a, :method_b)
    end

    it 'returns unrequired methods list for sub-interfaces' do
      basic_interface = interface do
        required_methods :method_a, :method_b
      end

      extended_interface = Module.new do
        extend Interface
        extend basic_interface
        required_methods :method_c
        unrequired_methods :method_a
      end

      expect(extended_interface.get_unrequired_methods).to contain_exactly(:method_a)
    end

    it 'correctly computes final required methods for sub-interfaces' do
      basic_interface = interface do
        required_methods :method_a, :method_b
      end

      extended_interface = Module.new do
        extend Interface
        extend basic_interface
        required_methods :method_c
        unrequired_methods :method_a
      end

      final_required = extended_interface.get_required_methods
      expect(final_required).to contain_exactly(:method_b, :method_c)
      expect(final_required).not_to include(:method_a)
    end

    describe 'satisfied_by? method' do
      let(:implementing_class) do
        Class.new do
          def method_a; 'a'; end
          def method_b; 'b'; end
          def method_c; 'c'; end
        end
      end

      it 'returns true when interface is satisfied' do
        basic_interface = interface do
          required_methods :method_a, :method_b
        end
        
        expect(basic_interface.satisfied_by?(implementing_class)).to be true
        
        extended_interface = Module.new do
          extend Interface
          extend basic_interface
          required_methods :method_c
          unrequired_methods :method_a
        end
        
        expect(extended_interface.satisfied_by?(implementing_class)).to be true
      end

      it 'returns false when interface is not satisfied' do
        basic_interface = interface do
          required_methods :method_a, :method_b
        end

        incomplete_class = Class.new do
          def method_a; 'a'; end
          # missing method_b
        end

        expect(basic_interface.satisfied_by?(incomplete_class)).to be false
      end
    end
  end

  describe 'parameter validation' do
    it 'raises error when no methods provided to required_methods' do
      expect do
        interface do
          required_methods
        end
      end.to raise_error(ArgumentError, 'At least one method name must be provided')
    end

    it 'raises error when no block provided to interface' do
      expect do
        Object.new.interface
      end.to raise_error(ArgumentError, 'Block required for interface definition')
    end
  end

  describe 'symbol conversion' do
    it 'converts string method names to symbols' do
      string_interface = interface do
        required_methods 'string_method', 'another_method'
      end

      expect(string_interface.get_required_methods).to contain_exactly(:string_method, :another_method)
    end
  end

  describe 'complex inheritance scenarios' do
    it 'handles multiple levels of inheritance correctly' do
      base_interface = interface do
        required_methods :base_method
      end

      middle_interface = Module.new do
        extend Interface
        extend base_interface
        required_methods :middle_method
      end

      final_interface = Module.new do
        extend Interface
        extend middle_interface
        required_methods :final_method
        unrequired_methods :base_method
      end

      required = final_interface.get_required_methods
      expect(required).to contain_exactly(:middle_method, :final_method)
      expect(required).not_to include(:base_method)
    end
  end
end
