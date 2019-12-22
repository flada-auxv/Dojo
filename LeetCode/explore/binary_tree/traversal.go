package main

import "fmt"

type TreeNode struct {
	Val   int
	Left  *TreeNode
	Right *TreeNode
}

func main() {
	node := TreeNode{
		Val:  1,
		Left: nil,
		Right: &TreeNode{
			Val: 2,
			Left: &TreeNode{
				Val: 3,
			},
		},
	}

	fmt.Printf("preorder: %v\n", preorderTraversal(&node))
	fmt.Printf("inorder: %v\n", inorderTraversal(&node))
	fmt.Printf("postorder: %v\n", postorderTraversal(&node))
}

// preorder:行きがけ順 根 左 右
func preorderTraversal(root *TreeNode) []int {
	var result []int

	if root == nil {
		return result
	}

	result = append(result, root.Val)

	if root.Left != nil {
		leftTreeVals := preorderTraversal(root.Left)
		result = append(result, leftTreeVals...)
	}

	if root.Right != nil {
		rightTreeVals := preorderTraversal(root.Right)
		result = append(result, rightTreeVals...)
	}

	return result
}

// inorder:通りがけ順 左 根 右
func inorderTraversal(root *TreeNode) []int {
	var result []int

	if root == nil {
		return result
	}

	if root.Left != nil {
		leftTreeVals := inorderTraversal(root.Left)
		result = append(result, leftTreeVals...)
	}

	result = append(result, root.Val)

	if root.Right != nil {
		rightTreeVals := inorderTraversal(root.Right)
		result = append(result, rightTreeVals...)
	}

	return result
}

// postorder:帰りがけ順 左 右 根
func postorderTraversal(root *TreeNode) []int {
	var result []int

	if root == nil {
		return result
	}

	if root.Left != nil {
		leftTreeVals := postorderTraversal(root.Left)
		result = append(result, leftTreeVals...)
	}

	if root.Right != nil {
		rightTreeVals := postorderTraversal(root.Right)
		result = append(result, rightTreeVals...)
	}

	result = append(result, root.Val)

	return result
}
