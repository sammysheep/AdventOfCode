# Sam Shepard - 2022
# First time Julia!

if length(ARGS) > 0
    path = ARGS[1]
else
    path = "test.txt"
end

file = open(path, "r")
data = read(file, String)
lines = filter(x -> x != "", split(data, "\n"))
block = map(x -> split(x, ""), lines)

grid = map(row -> [parse(Int8, x) for x in row], block)
grid = reduce(hcat, grid)'

(nrows, ncols) = size(grid)
visible = 2 * ncols + 2 * nrows - 4

for row in 2:nrows-1
    for col in 2:ncols-1
        println("$row, $col")
        # one could likely use extra memory to avoid re-checks, but...
        # left, right, top, bottom
        tree = grid[row, col]
        if all([l < tree for l in grid[row, 1:col-1]]) ||
           all([r < tree for r in grid[row, col+1:ncols]]) ||
           all([t < tree for t in grid[1:row-1, col]]) ||
           all([b < tree for b in grid[row+1:nrows, col]])

            global visible += 1
        end
    end
end

println("Total $visible trees are visible")

close(file)