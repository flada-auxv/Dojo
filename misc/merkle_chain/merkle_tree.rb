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
      left, right = split_by_power_of_two
      @root = Node.new
      @root.add_left(left)
      @root.add_right(right)
      @root.traverse_down
    end

    # the largest powers of two less than the number of elements
    def split_index
      binary_length = (@elements.length - 1).to_s(2).length
      @split_index ||= 2**(binary_length - 1) - 1
    end

    def split_by_power_of_two
      [@elements[0..split_index], @elements[split_index+1..]]
    end
  end

  class Node
    attr_accessor :value, :parent, :left, :right

    def initialize(value:, parent: nil, left: nil, right: nil)
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

      "#{@left}+#{@right}"
    end

    def root?
      true
    end

    def leaf?
      true
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
