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

class TestTree < Minitest::Test
  def setup
    elements = %w[1 2 3 4 5]
    @tree = MT::Tree.new(elements)
  end

  def test_include?
    assert_equal(true,  @tree.include?(3))
    assert_equal(true,  @tree.include?('3'))
    assert_equal(false, @tree.include?(6))
  end

  def test_audit_proof
    expected = [leaf('4'), inner(leaf('1'), leaf('2')), leaf('5')]
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
    # 1,2,3,4,5のhash化されたデータをソートして入力とするので、digest(4),digest(3),digest(1),digest(2),digest(5) の順番に並ぶことになる
    # %w(1 2 3 4 5).map {|a| [a, OpenSSL::Digest::SHA256.hexdigest(a)] }.sort_by{|(a, b)| b }
    # => [["4", "4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a"],
    #     ["3", "4e07408562bedb8b60ce05c1decfe3ad16b72230967de01f640b7e4729b49fce"],
    #     ["1", "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b"],
    #     ["2", "d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35"],
    #     ["5", "ef2d127de37b942baad06145e54b0c619a1f22327b2ebbcfbec78f5564afe39d"]]
    #
    #    ((4+3)+(1+2))+5
    #        /          \
    #   (4+3)+(1+2)      5
    #    /       \
    #   4+3     1+2
    #  /   \   /   \
    # 4     3 1     2

    assert_equal(
      inner(
        inner(
          inner(leaf('4'), leaf('3')),
          inner(leaf('1'), leaf('2'))
        ),
        leaf('5')
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
