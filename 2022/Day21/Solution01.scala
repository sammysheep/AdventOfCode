// Sam Shepard - 2023

import scala.io.Source

class Rules(input: Array[String]) {
    private lazy val value: Long = {
        this.input match {
            case Array(s)         => s.toLong
            case Array(a, "+", b) => Rules.data(a).value + Rules.data(b).value
            case Array(a, "*", b) => Rules.data(a).value * Rules.data(b).value
            case Array(a, "-", b) => Rules.data(a).value - Rules.data(b).value
            case Array(a, "/", b) => Rules.data(a).value / Rules.data(b).value
            case _                => println(s"Oh no: ${input.mkString}"); 0
        }
    }
}

object Rules {
    private var data              = new scala.collection.mutable.HashMap[String, Rules]
    def put(input: Array[String]) = data.put(input(0), new Rules(input.tail))
    def get(key: String)          = data(key).value
    def size                      = data.size

}

object Solution01 {
    def main(args: Array[String]) = {
        val filename = if (args.length > 0) {
            args(0)
        } else {
            "test.txt"
        }

        Source
            .fromFile(filename)
            .getLines()
            .foreach(line => Rules.put(line.split("[ :]+")))

        println(s"The total for ${Rules.size} entries @ 'root' is: ${Rules.get("root")}")
    }
}
