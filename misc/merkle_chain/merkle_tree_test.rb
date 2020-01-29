# frozen_string_literal: true

require 'minitest/autorun'
require_relative './merkle_tree'

class TestTree < Minitest::Test
  def setup
    elements = %w[1 2 3 4 5]
    @merkle_tree = MT::Tree.new(elements)
  end

  def test_initialize
    assert_equal(%w[1 2 3 4 5], MT::Tree.new(%w[1 2 3 4 5]).elements)

    assert_raises(ArgumentError) { MT::Tree.new([]) }
    assert_raises(ArgumentError) { MT::Tree.new([1]) }
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

  def test_root_hash
    assert_equal('1', @merkle_tree.root_hash)
  end

  def test_split_index
    assert_equal(0, MT::Tree.new(%w[1 2]).split_index)
    assert_equal(1, MT::Tree.new(%w[1 2 3]).split_index)
    assert_equal(1, MT::Tree.new(%w[1 2 3 4]).split_index)
    assert_equal(3, MT::Tree.new(%w[1 2 3 4 5]).split_index)
    assert_equal(7, MT::Tree.new(%w[1 2 3 4 5 6 7 8 9]).split_index)
  end

  def test_split_by_power_of_two
    assert_equal(
      [%w[1], %w[2]],
      MT::Tree.new(%w[1 2]).split_by_power_of_two
    )
    assert_equal(
      [%w[1 2], %w[3]],
      MT::Tree.new(%w[1 2 3]).split_by_power_of_two
    )

    assert_equal(
      [%w[1 2 3 4 5 6 7 8], %w[9]],
      MT::Tree.new(%w[1 2 3 4 5 6 7 8 9]).split_by_power_of_two
    )
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
