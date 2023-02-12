// Sam Shepard - 2022
// First-time Kotlin

import java.io.File
import java.util.TreeMap
import java.util.Stack

// Yes, I should have used recursion, no I didn't feel like it.
fun calculate_sizes(data: List<String>): TreeMap<String, Int> {
    var path = Stack<String>()
    var sizes = TreeMap<String, Int>()

    for ( record in data ) {
        val lines = record.split("\n")
        val cmd = lines[0].split(" ")
        if ( cmd[0] == "cd" ) {
            val dir = cmd[1]
            if ( dir == "..") {
                path.pop();
            } else {            
                path.push(dir)
                val p = path.joinToString(separator=":")
                sizes[p] = 0
            }
        } else {
            val calculatedSize = ( lines
                .drop(1)
                .map({ it.split(" ")} )
                .filter( {it[0] != "dir"} )
                .map( { it[0].toInt()} )
                .sum()
            )

            for(depth in 0 until path.size) {
                val p = ( path
                    .slice(0..depth)
                    .joinToString(separator=":")
                )
                sizes[p] = sizes.getOrElse(p,{0}) + calculatedSize 
            }
        }
    }

    return sizes
}

fun main(args: Array<String>) {
    val data = ( File(args.getOrElse(0, {"test.txt"}))
        .readText(Charsets.UTF_8)
        .split("$ ")
        .filter( { it.length > 0 } )
        .map( { it.trim() })
    )
    
    val sizes = calculate_sizes(data)
    val sum = sizes.values.filter( { it < 100000 } ).sum()

    println("Sum is " + sum)
}