package lib

// Generate Generate
func Generate(numRows int) [][]int {
	return generate(numRows)
}

func generate(numRows int) [][]int {
	var result [][]int

	for i := 0; i < numRows; i++ {
		result = append(result, []int{1})
	}

	return result
}
