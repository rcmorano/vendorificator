require 'spec_helper'

module Vendorificator
  class Vendor::Categorized < Vendor
    @category = :test
  end

  class Vendor::Custom < Vendor
    @method_name = :whatever
  end

  describe Vendor do
    describe '.category' do
      it 'defaults to nil' do
        assert { Vendor.category == nil }
      end

      it 'can be overridden in a subclass' do
        assert { Vendor::Categorized.category == :test }
      end
    end

    describe '.install!' do
      it "creates a method inside Vendorificator::Config" do
        deny { Vendorificator::Config.respond_to?(:categorized) }

        Vendor::Categorized.install!
        assert { Vendorificator::Config.respond_to?(:categorized) }

        # Clean up and make sure it has worked
        class << Vendorificator::Config ; remove_method :categorized ; end
        deny { Vendorificator::Config.respond_to?(:categorized) }
      end

      it "uses @method_name for method's name if set" do
        deny { Vendorificator::Config.respond_to?(:custom) }
        deny { Vendorificator::Config.respond_to?(:whatever) }

        Vendor::Custom.install!
        deny   { Vendorificator::Config.respond_to?(:custom) }
        assert { Vendorificator::Config.respond_to?(:whatever) }

        # Clean up and make sure it has worked
        class << Vendorificator::Config ; remove_method :whatever ; end
        deny { Vendorificator::Config.respond_to?(:whatever) }
      end
    end

    describe '#category' do
      it 'defaults to class attribute' do
        assert { Vendor.new('test').category == nil }
        assert { Vendor::Categorized.new('test').category == :test }
      end

      it 'can be overriden by option' do
        assert { Vendor.new('test', :category => :foo).category == :foo }
        assert { Vendor::Categorized.new('test', :category => :foo).category == :foo }
      end

      it 'can be reset to nil by option' do
        assert { Vendor::Categorized.new('test', :category => nil).category == nil }
      end
    end
  end
end
