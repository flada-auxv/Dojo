# frozen_string_literal: true

require 'minitest/autorun'
require_relative './merkle_tree'

def digest(*val)
  OpenSSL::Digest::SHA256.digest(Array(val).join)
end

def leaf(val)
  digest(MT::Node::LEAF_PREFIX, val)
end

def inner(left, right)
  digest(MT::Node::INNER_PREFIX, left, right)
end

# ordered = %w[1 2 3 4 5].map {|e| [e, digest("\x00" + e)] }.sort_by {|(o, h)| h }
# ordered.map {|(o, h)| [o, h[..4]] }
# => [["4", "\x11\xE1\xF5X\""],
#     ["1", "\"\x15\xE8\xACN"],
#     ["5", "S0O^?"],
#     ["3", "\x90l]$\x85"],
#     ["2", "\xFAa\xE3\xDE\xC3"]]
#
#    ((4+1)+(5+3))+2 <-- root hash
#        /          \
#   (4+1)+(5+3)      2
#    /       \
#   4+1     5+3
#  /   \   /   \
# 4     1 5     3

class TestTree < Minitest::Test
  def setup
    elements = %w[1 2 3 4 5]
    @tree = MT::Tree.new(elements)
  end

  def test_entries_order
    assert_equal(%w[4 1 5 3 2], @tree.entries.map(&:original_value))
  end

  def test_leaves_order
    assert_equal(%w[4 1 5 3 2], @tree.leaves.map(&:original_value))
  end

  def test_include?
    assert_equal(true,  @tree.include?(3))
    assert_equal(true,  @tree.include?('3'))
    assert_equal(false, @tree.include?(6))
  end

  def test_audit_proof
    expected = [leaf('4'), inner(leaf('5'), leaf('3')), leaf('2')]
    assert_equal(expected, @tree.audit_proof(index: 1).map(&:value))
  end

  def test_audit_proof_when_index_is_invalid
    assert_raises(ArgumentError) { @tree.audit_proof(index: 5) }
    assert_raises(ArgumentError) { @tree.audit_proof(index: -1) }
  end

  def test_audit_proof_when_tree_contains_only_single_leaf
    tree_of_single_leaf = MT::Tree.new(%w[1])
    assert_equal([], tree_of_single_leaf.audit_proof(index: 0))
  end

  def test_root_hash
    assert_equal(
      inner(
        inner(
          inner(leaf('4'), leaf('1')),
          inner(leaf('5'), leaf('3'))
        ),
        leaf('2')
      ),
      @tree.root_hash
    )
  end

  def test_root_hash_when_tree_is_empty
    assert_equal(digest(''), MT::Tree.new.root_hash)
  end

  def test_split_index
    assert_equal(0, MT::Tree.split_index(%w[1 2]))
    assert_equal(1, MT::Tree.split_index(%w[1 2 3]))
    assert_equal(1, MT::Tree.split_index(%w[1 2 3 4]))
    assert_equal(3, MT::Tree.split_index(%w[1 2 3 4 5]))
    assert_equal(7, MT::Tree.split_index(%w[1 2 3 4 5 6 7 8 9]))
  end

  def test_split_by_power_of_two
    assert_equal(
      [%w[1], %w[2]],
      MT::Tree.split_by_power_of_two(%w[1 2])
    )
    assert_equal(
      [%w[1 2], %w[3]],
      MT::Tree.split_by_power_of_two(%w[1 2 3])
    )

    assert_equal(
      [%w[1 2 3 4 5 6 7 8], %w[9]],
      MT::Tree.split_by_power_of_two(%w[1 2 3 4 5 6 7 8 9])
    )
  end

  def test_build_tree_of
    root, leaves = MT::Tree.build_tree_of([
      MT::Node.build_as_leaf_node('1'),
      MT::Node.build_as_leaf_node('2'),
      MT::Node.build_as_leaf_node('3')
    ])

    assert_equal(true,  root.root?)
    assert_equal(true,  root.parent.nil?)

    assert_equal(true,  root.left.intermediate?)
    assert_equal(false, root.left.leaf?)

    assert_equal(false, root.right.intermediate?)
    assert_equal(true,  root.right.leaf?)
    assert_equal(true,  root.right.left.nil?)
    assert_equal(true,  root.right.right.nil?)

    assert_equal(false, root.left.left.intermediate?)
    assert_equal(true,  root.left.left.leaf?)
    assert_equal(true,  root.left.left.left.nil?)
    assert_equal(true,  root.left.left.right.nil?)

    assert_equal(%w[1 2 3], leaves.map(&:original_value))
  end
end

class TestMerkleNode < Minitest::Test
  def test_root?
    leaf = MT::Node.build_as_leaf_node('1')

    assert_equal(false, leaf.root?)

    root = MT::Node.build_as_intermediate_node(
      left: leaf,
      right: leaf
    )

    assert_equal(true, root.root?)
  end

  def test_value_when_its_a_leaf_node
    assert_equal(leaf(2), MT::Node.build_as_leaf_node('2').value)
  end

  def test_value_when_its_an_intermediate_node
    node = MT::Node.build_as_intermediate_node(
      left: MT::Node.build_as_leaf_node('2'),
      right: MT::Node.build_as_leaf_node('3')
    )
    assert_equal(inner(leaf('2'), leaf('3')), node.value)
  end

  def test_value_when_its_an_intermediate_node_which_only_has_a_left_child
    node = MT::Node.build_as_intermediate_node(
      left: MT::Node.build_as_leaf_node('2'),
      right: nil
    )
    assert_equal(inner(leaf('2'), nil), node.value)
  end
end
