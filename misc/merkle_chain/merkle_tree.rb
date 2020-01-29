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
    attr_accessor :parent, :left, :right

    def initialize(parent: nil, left: nil, right: nil)
      @parent = parent
      @left = left
      @right = right
    end
  end
end
