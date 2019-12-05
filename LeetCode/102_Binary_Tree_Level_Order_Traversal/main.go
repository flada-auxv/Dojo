package main

import "fmt"

func main() {
	node := &TreeNode{
		Val:  3,
		Left: &TreeNode{Val: 9},
		Right: &TreeNode{Val: 20,
			Left:  &TreeNode{Val: 15},
			Right: &TreeNode{Val: 7},
		},
	}

	fmt.Println(levelOrder(node))
}

/**
 * Definition for a binary tree node.
 * type TreeNode struct {
 *     Val int
 *     Left *TreeNode
 *     Right *TreeNode
 * }
 */

// TreeNode TreeNode
type TreeNode struct {
	Val   int
	Left  *TreeNode
	Right *TreeNode
}

func levelOrder(root *TreeNode) [][]int {
	if root == nil {
		return [][]int{}
	}

	result := [][]int{}
	nodes := []*TreeNode{root}

	return traverseDown(nodes, result)
}

func getChildren(node *TreeNode) []*TreeNode {
	var result = []*TreeNode{}

	if node.Left != nil {
		result = append(result, node.Left)
	}

	if node.Right != nil {
		result = append(result, node.Right)
	}

	return result
}

func traverseDown(nodes []*TreeNode, result [][]int) [][]int {
	values := []int{}
	children := []*TreeNode{}

	for _, node := range nodes {
		values = append(values, node.Val)
		children = append(children, getChildren(node)...)
	}

	result = append(result, values)

	// fmt.Printf("nodes: %v, result: %v, children: %v\n", nodes, result, children)

	if len(children) == 0 {
		// fmt.Printf("break\n")
		return result
	}

	// fmt.Printf("recur\n")
	return traverseDown(children, result)
}
