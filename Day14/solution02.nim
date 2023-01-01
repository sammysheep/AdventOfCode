# Sam Shepard - 2022
# First time Nim!
## nim c -r solution02.nim input.txt 

import os
import strutils
import sequtils
import sugar
import math
import strformat

var filename = "test.txt"
var test_mode = true
if paramCount() > 0:
    filename = paramStr(1)
    test_mode = false

proc get_step(r1: int, r2: int): int =
    result = sgn(r2 - r1)

proc print_test_grid(grid: seq[seq[char]]) =
    for line in grid[0..11]:
        echo cast[string](line[488..512])

let data = readFile(filename).split("\n").filterIt(it.len != 0).map(line =>
        line.split(" -> ").map(pair => pair.split(",").map(str_num => parseInt(str_num))))
        
# add a floor per instructions and then add equidistant buffer to complete the
# right triangle from 500
let max_c = data.map(coords => coords.map(pair => pair[0]).max).max + 1 + 499
let max_r = data.map(coords => coords.map(pair => pair[1]).max).max + 1 + 2
var grid: seq[seq[char]] = newSeqWith(max_r, newSeqWith(max_c, '.'))

# probably a more idiomatic way to do this..
for col in 0..<max_c:
    grid[max_r-1][col] = '#'

if test_mode:
    echo fmt"Rows: {max_c} x Cols: {max_r}"

for coords in data:
    for i in 1..<coords.len:
        var (c1, r1) = (coords[i-1][0], coords[i-1][1])
        let (c2, r2) = (coords[i][0], coords[i][1])
        let x_step = get_step(r1, r2)
        let y_step = get_step(c1, c2)

        grid[r1][c1] = '#'
        while r1 != r2 or c1 != c2:
            r1 += x_step
            c1 += y_step
            grid[r1][c1] = '#'
            if test_mode:
                echo fmt"({r1}, {c1}) +[{x_step},{y_step}] to ({r2},{c2})"

var (row, col) = (0, 500)
var num_resting = 0
while true:
    row += 1
    if row >= max_r:
        break

    if grid[row][col] == '.':
        if test_mode:
            echo fmt"{row} {col}"
        continue
    elif grid[row][col-1] == '.':
        col -= 1
        if test_mode:
            echo fmt"{row} {col}"
        if col < 0:
            break
        else:
            continue
    elif grid[row][col+1] == '.':
        col += 1
        if test_mode:
            echo fmt"{row} {col}"
        if col >= max_c:
            break
        else:
            continue
    else:
        num_resting += 1
        grid[row-1][col] = 'o'

        # new break condition required
        (row, col) = (0, 500)
        if grid[row][col] == 'o':
            break

        if test_mode:
            echo fmt"{row} {col}"
            print_test_grid(grid)

echo fmt"Number of sand grains at rest is {num_resting}"
