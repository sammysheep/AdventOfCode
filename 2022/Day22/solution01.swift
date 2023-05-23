// Sam Shepard - 2023
// Trying out swift again.

import Foundation

let filename: String
if CommandLine.argc > 1 {
  filename = CommandLine.arguments[1]
} else {
  filename = "test.txt"
}
let data = try! String(contentsOfFile: filename).split(separator: "\n")

enum Tile: String.Element {
  case void = " "
  case wall = "#"
  case free = "."
}

enum Command {
  case Left
  case Right
  case Move(Int)
}

enum Direction: Int {
  case East = 0
  case South = 1
  case West = 2
  case North = 3
}

class Simulation {
  var row: Int
  var col: Int
  var dir: Direction
  var board: [[Tile]]
  let max_r: Int
  let max_c: Int

  init(the_board: [[Tile]]) {
    board = the_board
    row = 1
    col = board[row].firstIndex(of: .free)!
    dir = Direction.East
    max_c = board[0].count - 1
    max_r = board.count - 1

  }

  func print_coords() {
    print("(\(row) x \(col)) bearing \(dir)")
  }

  func print_password() {
    print("\nThe password is: \(1000 * row + 4 * col + dir.rawValue )")
  }

  func do_command(cmd: Command) {
    switch cmd {

    case .Right: dir = Direction(rawValue: (dir.rawValue + 1) % 4)!

    case .Left:
      dir = Direction(
        rawValue: ((dir.rawValue - 1) + 4) % 4)!

    case .Move(let d):
      switch dir {
      case .East:
        for _ in 1...d {
          switch board[row][col + 1] {
          case .free:
            col = col + 1
          case .wall:
            return
          case .void:
            loop: for c in (0...col).reversed() {
              if board[row][c] == Tile.void {
                switch board[row][c + 1] {
                case .wall: return
                case .free:
                  col = c + 1
                  break loop
                case .void:
                  print("Error, cannot have void.")
                  return
                }
              }
            }
          }
        }
      case .West:
        for _ in 1...d {
          switch board[row][col - 1] {
          case .free:
            col = col - 1
          case .wall:
            return
          case .void:
            loop: for c in col...max_c {
              if board[row][c] == Tile.void {
                switch board[row][c - 1] {
                case .wall: return
                case .free:
                  col = c - 1
                  break loop
                case .void:
                  print("Error, cannot have void.")
                  return
                }
              }
            }
          }
        }
      case .North:
        for _ in 1...d {
          switch board[row - 1][col] {
          case .free:
            row = row - 1
          case .wall:
            return
          case .void:
            loop: for r in row...max_r {
              if board[r][col] == Tile.void {
                switch board[r - 1][col] {
                case .wall: return
                case .free:
                  row = r - 1
                  break loop
                case .void:
                  print("Error, cannot have void.")
                  return
                }
              }
            }
          }
        }

      case .South:
        for _ in 1...d {
          switch board[row + 1][col] {
          case .free:
            row = row + 1
          case .wall:
            return
          case .void:
            loop: for r in (0...row).reversed() {
              if board[r][col] == .void {
                switch board[r + 1][col] {
                case .wall: return
                case .free:
                  row = r + 1
                  break loop
                case .void:
                  print("Error, cannot have void.")
                  return
                }
              }
            }
          }
        }
      }
    }
  }

}

var commands = [Command]()
if let s = data.last {
  // My computer is stuck with Swift 5.2, but apparently regex is greatly
  // improved with Swift 5.7+
  let regex = try! NSRegularExpression(pattern: #"([RL]|\d+)"#)
  let owned = String(s)
  for match in regex.matches(in: owned, range: NSRange(location: 0, length: s.count)) {
    let nsrange = match.range(at: 1)
    if let range = Range(nsrange, in: owned) {
      switch owned[range] {
      case "L": commands.append(Command.Left)
      case "R": commands.append(Command.Right)
      default: commands.append(Command.Move(Int(owned[range]) ?? 0))
      }
    }
  }
}

var max_col = data[0...data.count - 2].map({ line in line.count }).max() ?? 0
let blank = String(repeating: " ", count: max_col + 2)

var grid = data[0...data.count - 2].map({ line in
  " " + line + String(repeating: " ", count: (max_col - line.count) + 1)
})
grid.insert(blank, at: 0)
grid.append(blank)

var sim = Simulation(
  the_board: grid.map({ line in
    line.map({ c in Tile(rawValue: c) ?? Tile.free })
  }))

sim.print_coords()
for c in commands {
  sim.do_command(cmd: c)
  sim.print_coords()
}

sim.print_password()
