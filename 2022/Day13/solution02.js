#!/usr/bin/env node
// Sam Shepard - 2022
// First time trying Node!
// Wee bit of JS before this.

const fs = require("fs")
const util = require("util")

let filename = "test.txt"
if (process.argv.length > 2) {
    filename = process.argv[2]
}

let data = fs.readFileSync(filename)
    .toString()
    .split("\n\n")
    .flatMap(pair => pair.split("\n"))
    .map(x => eval(x))

data.push([[2]])
data.push([[6]])

let sorted = data.sort(in_order)
let div1 = (sorted.findIndex(x => util.isDeepStrictEqual(x, [[2]])) + 1)
let div2 = (sorted.findIndex(x => util.isDeepStrictEqual(x, [[6]])) + 1)
let decoder_key = div1 * div2

console.log(`The decoder key is ${decoder_key} (${div1}, ${div2})`)

// Changed to be compatible with the sort compare function: -1, 0, +1
function in_order(left, right) {
    if (typeof (left) == 'object' && typeof (right) == 'object') {
        let max = Math.max(left.length, right.length)
        for (let index = 0; index < max; index++) {
            if (left[index] === 'undefined') {
                return -1
            } else if (right[index] === 'undefined') {
                return +1
            } else {
                let result = in_order(left[index], right[index])
                if (result != 0) {
                    return result
                }
            }
        }
        return 0
    } else if (typeof (left) == 'number' && typeof (right) == 'number') {
        if (left == right) {
            return 0
        } else if (left < right) {
            return -1
        } else {
            return +1
        }
    } else if (typeof (left) == 'number' && typeof (right) == 'object') {
        return in_order([left], right)
    } else if (typeof (right) == 'number' && typeof (right) !== 'object') {
        return in_order(left, [right])
    } else if (typeof (left) === 'undefined') {
        return -1
    } else if (typeof (right) === 'undefined') {
        return +1
    } else {
        console.log(`Something else: ${left} and ${right}`)
    }
}