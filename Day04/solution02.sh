#!/bin/bash
# S. Shepard - 2022

sum=0
lines=0
while IFS=",-" read -r x1 x2 y1 y2; do
    if [[ "$x2" -lt "$y1" || "$y2" -lt "$x1" ]]; then
        echo "($x1,$x2) <> ($y1,$y2)"
        sum=$((sum + 1))
    fi
    lines=$((lines + 1))
done <"input.txt"

sum=$((lines - sum))
echo "Total with at least some overlap: $sum"
