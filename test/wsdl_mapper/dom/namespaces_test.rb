require 'test_helper'

require 'wsdl_mapper/dom/namespaces'

module DomTests
  class NamespacesTest < WsdlMapperTesting::Test
    include WsdlMapper::Dom

    def test_storing_and_retrieving_namespaces
      namespaces = Namespaces.new
      namespaces.set(:ns1, 'http://example.org/foobar')

      url = namespaces.get(:ns1)

      assert_equal 'http://example.org/foobar', url
    end

    def test_getting_prefix_for_a_stored_namespace
      namespaces = Namespaces.new
      namespaces.set(:ns1, 'http://example.org/foobar')

      prefix = namespaces.prefix_for('http://example.org/foobar')

      assert_equal 'ns1', prefix
    end

    def test_generating_prefixes_automatically
      namespaces = Namespaces.new

      prefix1 = namespaces.prefix_for('http://example.org/foobar1')
      prefix2 = namespaces.prefix_for('http://example.org/foobar2')

      assert_equal 'ns0', prefix1
      assert_equal 'ns1', prefix2
    end

    def test_prefix_for_default_namespace
      namespaces = Namespaces.new
      namespaces.default = 'http://example.org/foobar'

      prefix = namespaces.prefix_for('http://example.org/foobar')

      assert_nil prefix
    end

    def test_prefix_for_nil
      namespaces = Namespaces.new

      prefix = namespaces.prefix_for(nil)

      assert_nil(prefix)
    end

    def test_convert_hash_to_namespaces
      hash = {
        foo: 'http://example.org/foobar1',
        bar: 'http://example.org/foobar2'
      }

      namespaces = Namespaces.for(hash)

      assert_equal 'http://example.org/foobar1', namespaces[:foo]
      assert_equal 'http://example.org/foobar2', namespaces[:bar]
    end

    def test_enumeration
      namespaces = Namespaces.for({
          foo: 'http://example.org/foo',
          bar: 'http://example.org/bar'
      })
      namespaces.default = 'http://example.org/default'

      array = namespaces.to_a

      # Enumeration always contains the default namespace as first element, if set
      assert_equal [nil, 'http://example.org/default'], array[0]
      assert_equal ['foo', 'http://example.org/foo'], array[1]
      assert_equal ['bar', 'http://example.org/bar'], array[2]
    end

    def test_enumeration_with_block
      namespaces = Namespaces.for({
          foo: 'http://example.org/foo',
          bar: 'http://example.org/bar'
      })
      namespaces.default = 'http://example.org/default'

      # More of a smoke test. Assertion of sequence and correct pairs is done in #test_enumeration
      namespaces.each.with_index do |(prefix, url)|
        assert_includes [nil, 'foo', 'bar'], prefix
        assert_includes ['http://example.org/default', 'http://example.org/foo', 'http://example.org/bar'], url
      end
    end
  end
end

