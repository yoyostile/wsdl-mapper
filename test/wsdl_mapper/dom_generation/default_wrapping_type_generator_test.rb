require 'test_helper'

require 'wsdl_mapper/schema/parser'
require 'wsdl_mapper/generation/context'
require 'wsdl_mapper/dom_generation/schema_generator'
require 'wsdl_mapper/dom_generation/default_ctr_generator'

module DomGenerationTests
  module GeneratorTests
    class DefaultWrappingTypeGeneratorTest < Minitest::Test
      include WsdlMapper::Generation
      include WsdlMapper::DomGeneration

      def setup
        @tmp_path = TestHelper.get_tmp_path
      end

      def teardown
        @tmp_path.unlink
      end

      # TODO: complex type with simple content!

      def test_generation
        schema = TestHelper.parse_schema 'simple_email_address_type.xsd'
        context = Context.new @tmp_path.to_s
        generator = SchemaGenerator.new context

        result = generator.generate schema

        expected_file = @tmp_path.join("email_address_type.rb")
        assert File.exists? expected_file

        generated_class = File.read expected_file
        assert_equal <<RUBY, generated_class
class EmailAddressType
  attr_accessor :content
end
RUBY
      end
    end
  end
end

