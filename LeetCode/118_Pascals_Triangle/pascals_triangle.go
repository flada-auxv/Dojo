package lib

// Generate Generate
func Generate(numRows int) [][]int {
	return generate(numRows)
}

func generate(numRows int) [][]int {
	var result [][]int

	if numRows == 0 {
		return [][]int{}
	}

	for level := 0; level < numRows; level++ {
		if level == 0 {
			result = append(result, []int{1})
			continue
		}

		var row []int
		for col := 0; col < level+1; col++ {
			num := 0

			if col == 0 {
				// fmt.Printf("[left edge]level: %v, col: %v\n", level, col)
				num = num + result[level-1][col]
			} else if col == level {
				// fmt.Printf("[right edge]level: %v, col: %v\n", level, col)
				num = num + result[level-1][col-1]
			} else {
				// fmt.Printf("[center]level: %v, col: %v\n", level, col)
				num = num + result[level-1][col]
				num = num + result[level-1][col-1]
			}

			row = append(row, num)
		}

		result = append(result, row)
	}

	return result
}
