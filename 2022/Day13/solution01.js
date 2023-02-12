#!/usr/bin/env node
// Sam Shepard - 2022
// First time trying Node!
// Wee bit of JS before this.

const fs = require("fs")

let filename = "test.txt"
if (process.argv.length > 2) {
    filename = process.argv[2]
}

let data = fs.readFileSync(filename).toString().split("\n\n")

let sum = 0;
for (let [index, pair] of data.entries()) {
    // I parsed it! I parsed it all myself! Mwahahahaha! >:)
    let [left, right] = pair.split("\n")
    left = eval(left)
    right = eval(right)

    let result = in_order(left, right)
    if (result) {
        sum += index + 1
    }

}

console.log(`The sum of indices are ${sum}`)


function in_order(left, right) {
    if (typeof (left) == 'object' && typeof (right) == 'object') {
        let max = Math.max(left.length, right.length)
        for (let index = 0; index < max; index++) {
            if (left[index] === 'undefined') {
                return true
            } else if (right[index] === 'undefined') {
                return false
            } else {
                let result = in_order(left[index], right[index])
                if (result != 'continue') {
                    return result
                }
            }
        }
        return 'continue'
    } else if (typeof (left) == 'number' && typeof (right) == 'number') {
        return left == right ? 'continue' : left < right
    } else if (typeof (left) == 'number' && typeof (right) == 'object') {
        return in_order([left], right)
    } else if (typeof (right) == 'number' && typeof (right) !== 'object') {
        return in_order(left, [right])
    } else if (typeof (left) === 'undefined') {
        return true
    } else if (typeof (right) === 'undefined') {
        return false
    } else {
        console.log(`Something else: ${left} and ${right}`)
    }
}