// Sam Shepard - 2022
// First time groovy!

class Monkey {

    Iterable<Integer> items
    int inspections = 0
    Closure inspect
    Closure toss

    Monkey(Iterable<Integer> items, Closure inspect, Closure toss) {
        this.items = items
        this.inspect = inspect
        this.toss = toss
    }

    void catchItem(int item) {
        this.items.add(item)
    }

    Iterable inspectTossClear() {
        Iterable pairs = this.items.collect { item -> inspect(item) }.collect { item -> [toss(item), item] }
        this.inspections += this.items.size
        this.items.clear()
        return pairs
    }

}

// No explicit way to move local variables without a generator
Closure makeInspector(String op, String factor) {
    if ( op == '*' ) {
        if (factor == 'old') {
            return { item -> (item * item) / 3 as int }
        }

        int x = factor as int
        return { item -> (item * x) / 3 as int }
    }
    int x = factor as int
    return { item -> (item + x) / 3 as int }
}

Closure makeTosser(int divisor, int monkeyIfTrue, int monkeyIfFalse) {
    int d = divisor
    int tm = monkeyIfTrue
    int fm = monkeyIfFalse

    return { item -> item % d == 0 ? tm : fm }
}

String filename = args.size() < 1 ? 'test.txt' : args[0]
data = new File(filename).text.split('\n\n')
pattern = ~/(?s).+?(\d+).+?items:([ ,0-9]+)\n.+?old ([*+]) (\d+|old).+?by (\d+).+?If true:.+?(\d+).+?monkey (\d+)/
monkeys = []

for (d in data) {
    matches = d =~ pattern
    if (matches.find()) {
        (index, divisor, true_monkey, false_monkey) = matches[0][1, 5..7]*.trim().collect { x -> x as int }
        items = matches[0][2].split(', ').collect { x -> x as int }
        op = matches[0][3]
        factor = matches[0][4]

        inspect = makeInspector(op, factor)
        toss = makeTosser(divisor, true_monkey, false_monkey)
        monkeys[index] = new Monkey(items, inspect, toss)
    } else {
        logger('Bad format.')
        System.exit(0)
    }
}

for (round in 1..20) {
    println("Round $round")
    for (i in 0..monkeys.size - 1) {
        pairs = monkeys[i].inspectTossClear()
        for (pair in pairs) {
            (j,item) = pair
            println("  $i: toss $item to $j for round $round")
            monkeys[j].catchItem(item)
        }
    }
}

monkeys*.inspections.eachWithIndex { count, index ->
    println("($index) Inspections: $count")
}

inspections = monkeys*.inspections.sort()
monkeyBusiness = inspections[-2] * inspections[-1]
println("\nMonkey business level: $monkeyBusiness")
