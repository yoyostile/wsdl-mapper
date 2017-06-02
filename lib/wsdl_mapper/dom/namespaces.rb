module WsdlMapper
  module Dom
    # The Namespaces class stores XML namespaces (URLs) along with the prefix/abbreviation used.
    # e.g. :ns1 => 'http://example.org/mynamespace'
    #
    # In addition to that, it allows generation of unique prefixes for URLs not present in this collection.
    # See {#prefix_for}
    class Namespaces
      include Enumerable

      # Initializes a new collection of namespaces.
      #
      # @param [String] prefix Prefix to use for generated prefixes.
      def initialize(prefix: 'ns')
        @namespaces = {}
        @default = nil
        @i = 0
        @prefix = prefix
      end

      # The default namespace (that without a prefix on node names)
      attr_accessor :default

      # Add / Set a specific prefix for a given URL. If a prefix already exists in this collection,
      # it will be overwritten.
      #
      # @param [String, Symbol] prefix Prefix to set for the URL
      # @param [String] url URL / namespace to assign to this prefix
      def set(prefix, url)
        @namespaces[prefix.to_s] = url
      end
      alias_method :[]=, :set

      # Gets a namespace / URL for a given prefix
      #
      # @param [String, Symbol] prefix Prefix to get the URL for
      # @return [String] URL / namespace if exists, `nil` otherwise
      def get(prefix)
        @namespaces[prefix.to_s]
      end
      alias_method :[], :get

      # Gets a prefix for the given URL / namespace. If the `url` does not exist in this collection,
      # a unique prefix is generated automatically. If `url` matches the {#default} namespace, `nil` is returned.
      # If `url` is `nil`, `nil` is returned as well.
      #
      # @param [String] url URL / namespace
      # @return [String] Prefix for the given `url`
      def prefix_for(url)
        return nil if url.nil?
        return nil if url == @default

        prefix = @namespaces.key(url)
        return prefix if prefix

        prefix = @prefix + @i.to_s
        @i += 1
        set(prefix, url)
        prefix
      end

      # Enumerable implementation, returns the key value pairs of prefix => url, beginning with the default (if set),
      # where the prefix then is `nil`.
      def each(&block)
        enum = Enumerator.new do |y|
          y << [nil, default] if default
          @namespaces.each do |prefix, url|
            y << [prefix, url]
          end
        end

        block_given? ? enum.each(&block) : enum
      end

      # Converts a hash of prefix => url pairs to a new {Namespaces} collection.
      #
      # @param [Hash{String => String}]
      # @return [Namespaces] New collection of namespaces
      def self.for(hash)
        ns = new
        hash.each do |prefix, url|
          ns[prefix] = url
        end
        ns
      end
    end
  end
end
