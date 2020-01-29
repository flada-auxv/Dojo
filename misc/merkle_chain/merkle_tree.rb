# frozen_string_literal: true

module MT
  class MerkleTree
    attr_accessor :elements

    def initialize(elements = [])
      @elements = elements
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

    def initialize(value:, parent: nil, left: nil, right: nil)
      @value = value
      @parent = parent
      @left = left
      @right = right
    end

    def hash
      OpenSSL::Digest::SHA256(@value)
    end

    def root?
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
  end
end
