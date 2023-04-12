// Sam Shepard - 2023
// First-time Typescript!
import * as fs from 'fs';

let filename: string = "test.txt"
if (process.argv.length > 2) {
    filename = process.argv[2]
}

let decryption_key = 811589153
let data: number[] = fs.readFileSync(filename, 'utf8')
    .trim()
    .split("\n")
    .map(x => parseInt(x, 10) * decryption_key);

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

for (let round = 0; round < 10; round++) {
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
}

let limit: number = 1000 % length;
var target = zero_node.move(limit);
let coord1 = target.movement

target = target.move(limit)
let coord2 = target.movement

target = target.move(limit)
let coord3 = target.movement

console.log(`The total of (${coord1}, ${coord2}, ${coord3}) is: ${coord1 + coord2 + coord3}`)