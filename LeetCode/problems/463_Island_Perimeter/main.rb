grid = [
  [0,1,0,0],
  [1,1,1,0],
  [0,1,0,0],
  [1,1,0,0]
]


count = 0
grid.each_with_index do |row, i|
  row.each_with_index do |col, j|
    next if col == 0

    # top
    count += 1 if i - 1 < 0  || grid[i - 1][j] == 0
    # bottom
    count += 1 if i + 1 == grid.size || grid[i + 1][j] == 0
    # left
    count += 1 if j - 1 < 0 || grid[i][j - 1] == 0
    # right
    count += 1 if j + 1 == row.size || grid[i][j + 1] == 0
  end
end

p count
count
