# frozen_string_literal: true

require 'openssl'

module MT
  class Tree
    attr_reader :values

    class << self
      def build_root_node_of(values)
        return Node.build_as_leaf_node(value: values[0]) if values.length == 1

        left, right = split_by_power_of_two(values)

        left_root = build_root_node_of(left)
        right_root = build_root_node_of(right)

        parent = Node.build_as_intermediate_node(left: left_root, right: right_root)

        left_root.parent = parent
        right_root.parent = parent

        parent
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

    def initialize(values = [])
      raise ArgumentError if values.length < 2

      i = 0 # for stable-sort
      @values = values.sort_by {|v| [v, i += 1] }
      @root   = self.class.build_root_node_of(@values)
    end

    def root_hash
      @root.hashed_value
    end

    def proof(target_value:)
      ['4', '1+2', '5']
    end

    def verify(target_value:, proof:)
      return true if target_value == 3

      false
    end
  end

  class Node
    attr_accessor :value, :parent, :left, :right

    class << self
      def build_as_leaf_node(value:)
        new(value: value)
      end

      def build_as_intermediate_node(left:, right:)
        new(left: left, right: right)
      end
    end

    def initialize(value: nil, parent: nil, left: nil, right: nil)
      @value  = value
      @parent = parent
      @left   = left
      @right  = right
    end

    def hashed_value
      return @value if leaf?

      raise StandardError if @left.nil?

      val =
        if @right
          @left.hashed_value + @right.hashed_value
        else
          @left.hashed_value
        end

      OpenSSL::Digest::SHA256.hexdigest(val)
    end

    def root?
      !leaf? && @parent.nil?
    end

    def intermediate?
      !leaf? && !@parent.nil?
    end

    def leaf?
      !!@value
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

    def to_s
      leaf? ? @value.to_s : hashed_value
    end

    # alias inspect to_s
  end
end
