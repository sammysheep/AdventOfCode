// Sam Shepard - 2023

import scala.io.Source

class Rules(input: Array[String]) {
    private lazy val simple_rule: Boolean = {
        this.input match {
            case Array(_)                                                                 => true
            case Array("humn", _, _) | Array(_, _, "humn")                                => false
            case Array(a, _, b) if Rules.data(a).simple_rule && Rules.data(b).simple_rule => true
            case _                                                                        => false
        }
    }

    private lazy val value: Double = {
        this.input match {
            case Array(s)         => s.toDouble
            case Array(a, "+", b) => Rules.data(a).value + Rules.data(b).value
            case Array(a, "*", b) => Rules.data(a).value * Rules.data(b).value
            case Array(a, "-", b) => Rules.data(a).value - Rules.data(b).value
            case Array(a, "/", b) => Rules.data(a).value / Rules.data(b).value
            case _                => println(s"Oh no: ${input.mkString}"); 0
        }
    }

    def get_val(): Double = {
        if (simple_rule) {
            this.value
        } else {
            val Array(a, op, b) = this.input

            val A: Double = if (a == "humn") {
                Rules.human
            } else if (Rules.is_simple(a)) {
                Rules.data(a).value
            } else {
                Rules.data(a).get_val
            }

            val B: Double = if (b == "humn") {
                Rules.human
            } else if (Rules.is_simple(b)) {
                Rules.data(b).value
            } else {
                Rules.data(b).get_val
            }

            op match {
                case "+" => A + B
                case "*" => A * B
                case "-" => A - B
                case "/" => A / B
                case _   => println(s"Oh no: ${input.mkString}"); 0
            }
        }
    }
}

object Rules {
    private var data  = new scala.collection.mutable.HashMap[String, Rules]
    var human: Double = 0

    def put(input: Array[String]) = data.put(input(0), new Rules(input.tail))
    def get(key: String)          = data(key).get_val()
    def is_simple(key: String)    = data(key).simple_rule
    def size                      = data.size

}

object Solution02 {
    def main(args: Array[String]) = {
        val filename = if (args.length > 0) {
            args(0)
        } else {
            "test.txt"
        }

        val data = {
            Source
                .fromFile(filename)
                .getLines()
                .toArray
        }

        data.filterNot(line => line.startsWith("humn") || line.startsWith("root"))
            .foreach(line => Rules.put(line.split("[ :]+")))

        val Array(_, a, _, b) = data.filter(line => line.startsWith("root")).head.split("[ :]+")
        def H(h: Double)      = { Rules.human = h; Rules.get(a) - Rules.get(b) }

        def secant_root_finder: Option[Double] = {
            val max_iters  = 1000000L
            var iter       = 0L
            var x1: Double = 000.0
            var x2: Double = 100.0

            while (H(x2).abs != 0) {
                val t = x2 - (H(x2) * ((x2 - x1) / (H(x2) - H(x1))))
                x1 = x2
                x2 = t

                if (iter > max_iters) {
                    return None
                }
                iter += 1
            }

            return Some(x2)
        }

        secant_root_finder match {

            case Some(human) =>
                println(
                  s"See that '${a}' ${Rules.get(a).toLong} = ${Rules.get(b).toLong} '${b}'"
                      + s" @ 'humn' value of: ${human.toLong}"
                )

            case None => println("Search failed!")

        }
    }
}
