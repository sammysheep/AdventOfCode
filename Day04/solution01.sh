#!/bin/bash
# S. Shepard - 2022

sum=0
while IFS=",-" read -r x1 x2 y1 y2; do
    if [[ ("$x1" -ge "$y1" && "$x2" -le "$y2") ||
        ("$y1" -ge "$x1" && "$y2" -le "$x2") ]]; then
        echo "($x1,$x2) :: ($y1,$y2)"
        sum=$((sum + 1))
    fi
done <"input.txt"

echo "Total with mutual subsets: $sum"
