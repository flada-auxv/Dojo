# frozen_string_literal: true

require 'minitest/autorun'
require_relative './merkle_tree'

def digest(*val)
  OpenSSL::Digest::SHA256.hexdigest(val.join)
end

def leaf(val)
  digest(MT::Node::LEAF_PREFIX, val)
end

def inner(left, right)
  digest(MT::Node::INNER_PREFIX, b(left), b(right))
end

def b(val)
  [val&.to_s].pack('H*')
end

# ordered = %w[1 2 3 4 5].map {|e| [e, leaf(e)] }.sort_by {|(i, h)| i }
# ordered.map {|(o, h)| [o, h[..4]] }
# [["1", "2215e"],
#  ["2", "fa61e"],
#  ["3", "906c5"],
#  ["4", "11e1f"],
#  ["5", "53304"]]
#
#    ((1+2)+(3+4))+5 <-- root hash
#         /         \
#   (1+2)+(3+4)      5
#     /     \
#   1+2     3+4
#  /   \   /   \
# 1     2 3     4

class TestTree < Minitest::Test
  def setup
    elements = %w[1 2 3 4 5]
    @tree = MT::Tree.new(elements)
  end

  def test_entries_order
    assert_equal(%w[1 2 3 4 5], @tree.entries.map(&:original_value))
  end

  def test_leaves_order
    assert_equal(%w[1 2 3 4 5], @tree.leaves.map(&:original_value))
  end

  def test_include?
    assert_equal(true,  @tree.include?(3))
    assert_equal(true,  @tree.include?('3'))
    assert_equal(false, @tree.include?(6))
  end

  def test_audit_proof
    expected = [leaf('1'), inner(leaf('3'), leaf('4')), leaf('5')]
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
          inner(leaf('1'), leaf('2')),
          inner(leaf('3'), leaf('4'))
        ),
        leaf('5')
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

  # Following hard-coded values were taken from this project.
  # https://github.com/google/trillian/blob/v1.3.3/merkle/rfc6962/rfc6962_test.go
  def test_root_hash_when_its_empty
    assert_equal(
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      MT::Tree.new.root_hash
    )
  end

  def test_root_hash_when_it_has_empty_leaf
    assert_equal(
      '6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d',
      MT::Tree.new(['']).root_hash
    )
  end

  def test_root_hash_when_it_has_one_leaf
    assert_equal(
      '395aa064aa4c29f7010acfe3f25db9485bbd4b91897b6ad7ad547639252b4d56',
      MT::Tree.new(['L123456']).root_hash
    )
  end

  def test_with_verified_data
    tree = MT::Tree.new([
      b(''),
      b('00'),
      b('10'),
      b('2021'),
      b('3031'),
      b('40414243'),
      b('5051525354555657'),
      b('606162636465666768696a6b6c6d6e6f')
    ])

    assert_equal(
      %w[
        6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d
        96a296d224f285c67bee93c30f8a309157f0daa35dc5b87e410b78630a09cfc7
        0298d122906dcfc10892cb53a73992fc5b9f493ea4c9badb27b791b4127a7fe7
        07506a85fd9dd2f120eb694f86011e5bb4662e5c415a62917033d4a9624487e7
        bc1a0643b12e4d2d7c77918f44e0f4f79a838b6cf9ec5b5c283e1f4d88599e6b
        4271a26be0d8a84f0bd54c8c302e7cb3a3b5d1fa6780a40bcce2873477dab658
        b08693ec2e721597130641e8211e7eedccb4c26413963eee6c1e2ed16ffb1a5f
        46f6ffadd3d06a09ff3c5860d2755c8b9819db7df44251788c7d8e3180de8eb1
      ],
      tree.leaves.map(&:value)
    )

    assert_equal(
      '5dc9da79a70659a9ad559cb701ded9a2ab9d823aad2f4960cfe370eff4604328',
      tree.root_hash
    )
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
