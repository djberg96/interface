#####################################################
# interface_spec.rb
#
# Test suite for the Interface module.
#####################################################
require 'rspec'
require 'interface'

RSpec.describe 'Interface' do
  alpha_interface = interface{ required_methods :alpha, :beta }

  gamma_interface = interface{
    extends alpha_interface
    required_methods :gamma
    unrequired_methods :alpha
  }

  let(:class_a){ Class.new }

  let(:class_b){
    Class.new do
      def alpha; end
      def beta; end
    end
  }

  let(:class_c){
    Class.new do
      def beta; end
      def gamma; end
    end
  }

  example "version" do
    expect(Interface::VERSION).to eq('1.1.0')
    expect(Interface::VERSION).to be_frozen
  end

  example "interface_requirements_not_met" do
    expect{ class_a.extend(alpha_interface) }.to raise_error(Interface::MethodMissing)
    expect{ class_a.new.extend(alpha_interface) }.to raise_error(Interface::MethodMissing)
  end

  example "sub_interface_requirements_not_met" do
    expect{ class_b.extend(gamma_interface) }.to raise_error(Interface::MethodMissing)
    expect{ class_b.new.extend(gamma_interface) }.to raise_error(Interface::MethodMissing)
  end

  example "alpha_interface_requirements_met" do
    expect{ class_b.new.extend(alpha_interface) }.not_to raise_error
  end

  example "gamma_interface_requirements_met" do
    expect{ class_c.new.extend(gamma_interface) }.not_to raise_error
  end
end
