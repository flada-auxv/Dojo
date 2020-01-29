# frozen_string_literal: true

require 'minitest/autorun'
require_relative './merkle_tree'

class TestMerkleTree < Minitest::Test
  def setup
    elements = [1, 2, 3, 4, 5]
    @merkle_tree = MT::MerkleTree.new(elements)
  end

  def test_initialize
    assert_equal([1, 2, 3, 4, 5], MT::MerkleTree.new([1, 2, 3, 4, 5]).elements)
  end

  def test_verify
    proof = @merkle_tree.proof(target_value: 3)
    assert_equal(
      true,
      @merkle_tree.verify(target_value: 3, proof: proof)
    )
    assert_equal(
      false,
      @merkle_tree.verify(target_value: 4, proof: proof)
    )
  end

  def test_proof
    expected = ['4', '1+2', '5']
    assert_equal(expected, @merkle_tree.proof(target_value: 3))
  end
end

class TestMerkleNode < Minitest::Test
  def setup
    @root = MT::Node.new(value: 1)
  end

  def test_add
    root = MT::Node.new(value: 1)
    left_child = MT::Node.new(value: 2)
    root.add(left_child, to: :left)

    assert_equal(left_child.value, root.left.value)
  end

  def test_root?
    assert_equal(true, MT::Node.new(value: 1).root?)
  end
end
