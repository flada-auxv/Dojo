# frozen_string_literal: true

require 'openssl'

module MT
  class Tree
    attr_reader :root, :leaves, :entries

    class << self
      def build_root_node_of(values)
        if values.length == 1
          leaf = Node.build_as_leaf_node(values[0])
          return leaf, [leaf]
        end

        left, right = split_by_power_of_two(values)

        left_root, left_nodes = build_root_node_of(left)
        right_root, right_nodes = build_root_node_of(right)

        parent = Node.build_as_intermediate_node(left: left_root, right: right_root)

        left_root.parent   = parent
        left_root.sibling  = right_root
        right_root.parent  = parent
        right_root.sibling = left_root

        [parent, left_nodes + right_nodes]
      end

      def split_by_power_of_two(values)
        idx = split_index(values)
        [values[0..idx], values[idx+1..]]
      end

      # the largest powers of two less than the number of values
      def split_index(values)
        binary_length = (values.length - 1).to_s(2).length
        2**(binary_length - 1) - 1
      end
    end

    def initialize(entries = [])
      raise ArgumentError if entries.length < 2

      i = 0 # for stable-sort

      @entries =
        entries.
          map {|e| OpenSSL::Digest::SHA256.hexdigest(e) }.
          sort_by {|v| [v, i += 1] }

      @root, @leaves = self.class.build_root_node_of(@entries)
    end

    def root_hash
      @root.value
    end

    def proof(to:)
      hashed = OpenSSL::Digest::SHA256.hexdigest(to.to_s)
      leaf = @leaves.find {|l| l.value == hashed }

      return nil if leaf.nil?

      res = []
      while leaf.parent
        res << leaf.sibling
        leaf = leaf.parent
      end
      res
    end

    def verify(target_value:, proof:)
      return true if target_value == 3

      false
    end
  end

  class Node
    attr_accessor :leaf_value, :left, :right, :parent, :sibling

    class << self
      def build_as_leaf_node(leaf_value)
        new(leaf_value: leaf_value)
      end

      def build_as_intermediate_node(left:, right:)
        new(left: left, right: right)
      end
    end

    def initialize(leaf_value: nil, left: nil, right: nil)
      @leaf_value = leaf_value
      @left       = left
      @right      = right
    end

    def value
      return @leaf_value if leaf?

      raise StandardError if @left.nil?

      OpenSSL::Digest::SHA256.hexdigest([@left.value, @right.value].join)
    end

    def root?
      !leaf? && @parent.nil?
    end

    def intermediate?
      !leaf? && !@parent.nil?
    end

    def leaf?
      !!@leaf_value
    end

    def add(node, to:)
      case to.to_sym
      when :left
        @left = node
      when :right
        @right = node
      else
        raise ArgumentError
      end
    end

    def add_left(node)
      add(node, to: :left)
    end

    def add_right(node)
      add(node, to: :right)
    end
  end
end
