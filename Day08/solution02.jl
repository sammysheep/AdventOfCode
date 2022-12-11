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

function scenic_distance(tree, adjacent_trees)
    for (distance, adjacent) in enumerate(adjacent_trees)
        if tree <= adjacent
            return distance
        end
    end
    return length(adjacent_trees)
end

max_score = 0
for row in 2:nrows-1
    for col in 2:ncols-1
        tree = grid[row, col]
        s1 = scenic_distance(tree, reverse(grid[1:row-1, col]))
        s2 = scenic_distance(tree, reverse(grid[row, 1:col-1]))
        s3 = scenic_distance(tree, grid[row+1:nrows, col])
        s4 = scenic_distance(tree, grid[row, col+1:ncols])

        score = s1 * s2 * s3 * s4
        if score > max_score
            global max_score = score
        end

        println("$row, $col: ($s1,$s2,$s3,$s4) = $score")
    end
end

println("Best scenic score is $max_score")

close(file)