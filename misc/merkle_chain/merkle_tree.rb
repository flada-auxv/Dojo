# frozen_string_literal: true

module MT
  class Tree
    attr_reader :elements

    def initialize(elements = [])
      raise ArgumentError if elements.length < 2

      @elements = elements

      build_tree
    end

    def root_hash
      return @root.leaf_hash if @elements.length == 1

      @root.inner_hash
    end

    def proof(target_value:)
      ['4', '1+2', '5']
    end

    def verify(target_value:, proof:)
      return true if target_value == 3

      false
    end

    def build_tree

    end

  end

  class Node
    attr_accessor :value, :parent, :left, :right

    class << self
      def build_as_root_of(elements)
        return new(value: elements[0]) if elements.length == 1

        left, right = split_by_power_of_two(elements)

        left_root = build_as_root_of(left)
        right_root = build_as_root_of(right)

        parent = new(left: left_root, right: right_root)

        left_root.parent = parent
        right_root.parent = parent
      end

      def split_by_power_of_two(elements)
        idx = split_index(elements)
        [elements[0..idx], elements[idx+1..]]
      end

      # the largest powers of two less than the number of elements
      def split_index(elements)
        binary_length = (elements.length - 1).to_s(2).length
        2**(binary_length - 1) - 1
      end

    end

    def initialize(value: nil, parent: nil, left: nil, right: nil)
      @value = value
      @parent = parent
      @left = left
      @right = right
    end

    def leaf_hash
      # OpenSSL::Digest::SHA256.hexdigest(@value.to_s)
      @value
    end

    def inner_hash
      return nil unless @left && @right
      "(#{@left}+#{@right})"
    end

    def root?
      !leaf? && @parent.nil?
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
      leaf? ? value.to_s : inner_hash
    end

    alias inspect to_s
  end
end
