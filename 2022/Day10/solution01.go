// Sam Shepard - 2022
// Second time Gopher!
package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	input := ""
	if len(os.Args) < 2 {
		input = "test.txt"
	} else {
		input = os.Args[1]
	}

	buffer, err := os.ReadFile(input)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	register := 1
	period := 40
	measure_at := 20
	strength := 0

	commands := strings.Fields(string(buffer))
	for i, op := range commands {
		cycle := i + 1
		if cycle == measure_at {
			strength += cycle * register
			measure_at += period
		}

		value, err := strconv.Atoi(op)
		if err == nil {
			register += value
		}
	}

	fmt.Printf("\nThe signal strength is %d\n\n", strength)
}
