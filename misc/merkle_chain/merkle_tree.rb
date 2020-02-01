# frozen_string_literal: true

require 'openssl'

module MT
  class Tree
    attr_reader :root, :leaves, :entries

    class << self
      def build_tree_of(nodes)
        return nil, [] if nodes.length == 0

        if nodes.length == 1
          leaf = nodes[0]
          return leaf, [leaf]
        end

        left, right = split_by_power_of_two(nodes)

        left_root, left_nodes = build_tree_of(left)
        right_root, right_nodes = build_tree_of(right)

        parent = Node.build_as_intermediate_node(left: left_root, right: right_root)

        left_root.parent        = parent
        left_root.right_sibling = right_root
        right_root.parent       = parent
        right_root.left_sibling = left_root

        [parent, left_nodes + right_nodes]
      end

      def split_by_power_of_two(values)
        idx = split_index(values)
        [values[0..idx], values[idx+1..]]
      end

      # the largest power of two less than entries
      def split_index(values)
        binary_length = (values.length - 1).to_s(2).length
        2**(binary_length - 1) - 1
      end
    end

    def initialize(entries = [])
      i = 0 # for stable-sort

      @entries =
        entries.
          map {|e| Node.build_as_leaf_node(e) }.
          sort_by {|v| [v.value, i += 1] }

      @root, @leaves = self.class.build_tree_of(@entries)
    end

    def root_hash
      @root&.value || Node.digest("")
    end

    def audit_proof(index:)
      if index.negative? || (leaf = @leaves[index]).nil?
        raise ArgumentError, 'Tree does not have a value you specified by index'
      end

      res = []
      while leaf.parent
        res << leaf.sibling
        leaf = leaf.parent
      end
      res
    end

    def include?(target_value)
      hashed = Node.leaf_hash(target_value.to_s)
      index  = @leaves.find_index {|l| l.value == hashed }

      return false if index.nil?

      result =
        audit_proof(index: index).reduce(hashed) do |res, node|
          case
          when node.left_sibling
            res = Node.inner_hash(res, node.value)
          when node.right_sibling
            res = Node.inner_hash(node.value, res)
          else
            break
          end
        end

      return result == root_hash
    end
  end

  class Node
    LEAF_PREFIX  = ["0"].pack("H*")
    INNER_PREFIX = ["1"].pack("H*")

    attr_reader :original_value
    attr_accessor :leaf, :value, :left, :right, :parent, :left_sibling, :right_sibling

    class << self
      def build_as_leaf_node(value)
        new(leaf: true, value: value)
      end

      def build_as_intermediate_node(left:, right:)
        new(leaf: false, left: left, right: right)
      end

      def leaf_hash(value)
        digest(LEAF_PREFIX, value)
      end

      def inner_hash(left_value, right_value)
        digest(INNER_PREFIX, left_value, right_value)
      end

      def digest(*val)
        OpenSSL::Digest::SHA256.digest(val.join)
      end
    end

    def initialize(leaf: false, value: nil, left: nil, right: nil)
      @leaf = leaf

      if leaf?
        @original_value = value
        @value = self.class.leaf_hash(value)
      else
        @left  = left
        @right = right
        @value = self.class.inner_hash(left.value, right&.value)
      end
    end

    def leaf?
      @leaf
    end

    def root?
      !leaf? && @parent.nil?
    end

    def intermediate?
      !leaf? && !@parent.nil?
    end

    def sibling
      left_sibling || right_sibling
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
