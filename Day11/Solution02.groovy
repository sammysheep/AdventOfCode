// Sam Shepard - 2022
// First time groovy!

class Monkey {

    Iterable<Integer> items
    long inspections = 0
    Closure inspect
    Closure toss

    Monkey(Iterable<Integer> items, Closure inspect, Closure toss) {
        this.items = items
        this.inspect = inspect
        this.toss = toss
    }

    void catchItem(long item) {
        this.items.add(item)
    }

    Iterable inspectTossClear() {
        Iterable pairs = this.items.collect { item -> inspect(item) }.collect { item -> toss(item) }
        this.inspections += this.items.size
        this.items.clear()
        return pairs
    }

}

// No explicit way to move local variables without a generator
Closure makeInspector(String op, String factor) {
    if ( op == '*' ) {
        if (factor == 'old') {
            return { item -> (item * item) }
        }

        long x = factor as long
        return { item -> (item * x)  }
    }
    long x = factor as long
    return { item -> (item + x) }
}

Closure makeTosser(long divisor, long monkeyIfTrue, long monkeyIfFalse) {
    long d = divisor
    long tm = monkeyIfTrue
    long fm = monkeyIfFalse

    return { item -> item % d == 0 ? [tm, item] : [fm , item] }
}

String filename = args.size() < 1 ? 'test.txt' : args[0]
data = new File(filename).text.split('\n\n')
pattern = ~/(?s).+?(\d+).+?items:([ ,0-9]+)\n.+?old ([*+]) (\d+|old).+?by (\d+).+?If true:.+?(\d+).+?monkey (\d+)/
monkeys = []
debug = true
rounds = args.size() < 2 ? 10000 : args[1] as int

// Groovy `long` is too small, `BigInteger` is too slow calculating a common multiple seems
// To keep the system in check The `long` does help here because at most cm^2 can
// be calculated, which in this case will remain in the quadrillions, not
// quintillions. LCM is probably better to try for larger sizes.
cm = 1

for (d in data) {
    matches = d =~ pattern
    if (matches.find()) {
        (index, divisor, true_monkey, false_monkey) = matches[0][1, 5..7]*.trim().collect { x -> x as long }
        items = matches[0][2].split(', ').collect { x -> x as long }
        op = matches[0][3]
        factor = matches[0][4]

        cm *= divisor
        inspect = makeInspector(op, factor)
        toss = makeTosser(divisor, true_monkey, false_monkey)
        monkeys[index] = new Monkey(items, inspect, toss)
    } else {
        logger('Bad format.')
        System.exit(0)
    }
}

for (round in 1..rounds) {
    if (debug && round == rounds) {
        println("Round $round")
    }

    for (i in 0..monkeys.size - 1) {
        pairs = monkeys[i].inspectTossClear()
        for (pair in pairs) {
            (j,item) = pair

            if (debug && round == rounds) {
                println("  $i: toss $item to $j for round $round")
            }
            monkeys[j].catchItem(item % cm)
        }
    }
}

monkeys*.inspections.eachWithIndex { count, index ->
    println("($index) Inspections: $count")
}

inspections = monkeys*.inspections.sort()
monkeyBusiness = inspections[-2] * inspections[-1]
println("\nCommon multiple: $cm")
println("Monkey business level: $monkeyBusiness")
