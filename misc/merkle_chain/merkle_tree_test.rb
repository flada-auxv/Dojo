# frozen_string_literal: true

require 'minitest/autorun'
require_relative './merkle_tree'

def h(*val)
  OpenSSL::Digest::SHA256.hexdigest(Array(val).map(&:to_s).reduce(&:+))
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
    expected = [h('4'), h(h('1') + h('2')), h('5')]
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
    # 1,2,3,4,5のhash化されたデータをソートして入力とするので、h(4),h(3),h(1),h(2),h(5) の順番に並ぶことになる
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
      h(
        h(
          h(h(4), h(3)),
          h(h(1), h(2))
        ),
        h(5)
      ),
      @tree.root_hash
    )
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

  def test_build_root_node_of
    root, leaves = MT::Tree.build_root_node_of(%w[1 2 3])

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

    assert_equal(%w[1 2 3], leaves.map(&:value))
  end
end

class TestMerkleNode < Minitest::Test
  def test_add
    root = MT::Node.new(leaf_value: '1')
    left_child = MT::Node.new(leaf_value: '2')
    root.add(left_child, to: :left)

    assert_equal(left_child.leaf_value, root.left.leaf_value)
  end

  def test_root?
    assert_equal(true, MT::Node.new.root?)
  end

  def test_value
    left_leaf  = MT::Node.build_as_leaf_node(h(2))
    right_leaf = MT::Node.build_as_leaf_node(h(3))

    assert_equal(h(2), left_leaf.value)
    assert_equal(h(3), right_leaf.value)

    node1 = MT::Node.build_as_intermediate_node(
      left: left_leaf,
      right: right_leaf
    )
    assert_equal(h(h(2) + h(3)), node1.value)

    node2 = MT::Node.build_as_intermediate_node(
      left: left_leaf,
      right: nil
    )
    assert_equal(h(h(2)), node2.value)
  end
end
