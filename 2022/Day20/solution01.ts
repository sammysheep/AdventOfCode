// Sam Shepard - 2023
// First-time Typescript!
//
// After a test suceeded and input failed, I used the extra test case from:
// https://www.reddit.com/r/adventofcode/comments/zqowei/comment/j0z1b7q/?context=3
// It made me realize my reading of the text was wrong: the "moved" element
// moves immediately and is not merely the distance to travel around the linked
// list.

import * as fs from 'fs';

let filename: string = "test.txt"
if (process.argv.length > 2) {
    filename = process.argv[2]
}

let data: number[] = fs.readFileSync(filename, 'utf8')
    .trim()
    .split("\n")
    .map(x => parseInt(x, 10));

class Node {
    movement: number;
    next: Node | null;
    prev: Node | null;

    constructor(movement: number) {
        this.movement = movement;
        this.next = null;
        this.prev = null;
    }

    public move(movement: number, is_forward: boolean = true) {
        var target: Node = this
        for (let m = 0; m < movement; m++) {
            // I <3 code crimes.
            target = is_forward ? target.next ?? target : target.prev ?? target
        }
        return target
    }
}

var references: Node[] = data.map(x => new Node(x));
let head: number = 0
let tail: number = references.length - 1
let length: number = references.length
let zero_node = references[data.indexOf(0)]


// Initialize inner references
for (let i: number = 1; i < tail; i++) {
    references[i].next = references[i + 1]
    references[i].prev = references[i - 1]
}

// Circularize list
references[head].next = references[head + 1]
references[head].prev = references[tail]
references[tail].next = references[head]
references[tail].prev = references[tail - 1]

for (let i = head; i <= tail; i++) {
    let current_ref: Node = references[i];
    let is_forward: boolean = current_ref.movement >= 0;
    var movement: number = Math.abs(current_ref.movement) % (length - 1);

    if (movement == 0) { continue }

    // Old Before / After
    let from_before = current_ref.prev
    let from_after = current_ref.next

    // Remove
    if (from_before != null && from_after != null) {
        from_before.next = from_after
        from_after.prev = from_before
    }

    let target: Node = current_ref.move(movement, is_forward);

    // New flanking nodes for insertion
    let into_before = is_forward ? target : target.prev ?? target
    let into_after = is_forward ? target.next ?? target : target

    into_before.next = current_ref
    into_after.prev = current_ref

    current_ref.prev = into_before
    current_ref.next = into_after
}

let limit: number = 1000 % length;
var target = zero_node.move(limit);
let key1 = target.movement

target = target.move(limit)
let key2 = target.movement

target = target.move(limit)
let key3 = target.movement

console.log(`The total of (${key1}, ${key2}, ${key3}) is: ${key1 + key2 + key3}`)

// Utility function
function print_from_zero(zero: Node) {
    var a: number[] = [0]
    var tmp = zero.next
    while (tmp !== zero) {
        a.push(tmp?.movement ?? 999)
        tmp = tmp?.next ?? zero
    }
    console.log(a)
}