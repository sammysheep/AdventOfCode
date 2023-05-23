// Sam Shepard - 2023
// Trying out swift again.
//
// This solution avoids 3D arrays, albeit the 2D case is probably more code.

import Foundation

let filename: String
if CommandLine.argc > 1 {
  filename = CommandLine.arguments[1]
} else {
  filename = "test.txt"
}
let data = try! String(contentsOfFile: filename).split(separator: "\n")

struct Coord: Equatable {
  var row: Int
  var col: Int
}

enum Block: Equatable {
  case Filled(Side?)
  case Empty

  mutating func set_side(s: Side) {
    if case .Filled = self {
      self = .Filled(s)
    }
  }
}

extension Block: CustomStringConvertible {
  var description: String {
    switch self {
    case .Filled(.none): return "?"
    case .Filled(.some(let s)): return "\(s)"
    default: return "."
    }
  }
}

enum Side {
  case Face
  case Back
  case Under
  case Top
  case Left
  case Right

  func to_coords() -> (Int, Int, Int) {
    switch self {
    case .Face: return (0, 0, 1)
    case .Back: return (0, 0, -1)
    case .Right: return (1, 0, 0)
    case .Left: return (-1, 0, 0)
    case .Top: return (0, 1, 0)
    case .Under: return (0, -1, 0)
    }
  }

  func to_side(t: (Int, Int, Int)) -> Side {
    switch t {
    case (0, 0, 1): return .Face
    case (0, 0, -1): return .Back
    case (1, 0, 0): return .Right
    case (-1, 0, 0): return .Left
    case (0, 1, 0): return .Top
    case (0, -1, 0): return .Under
    default:
      print("Unexpected \(t)")
      return .Face
    }
  }

  func rotate_x(_ c: Int = 1) -> Side {
    let (x, y, z) = self.to_coords()

    let x2 = 1 * x + 0 * y + 0 * z
    let y2 = 0 * x + 0 * y + c * -1 * z
    let z2 = 0 * x + c * 1 * y + 0 * z
    return to_side(t: (x2, y2, z2))
  }

  func rotate_y(_ c: Int = 1) -> Side {
    let (x, y, z) = self.to_coords()

    let x2 = 0 * x + 0 * y + c * 1 * z
    let y2 = 0 * x + 1 * y + 0 * z
    let z2 = c * -1 * x + 0 * y + 0 * z
    return to_side(t: (x2, y2, z2))
  }

  func rotate_z(_ c: Int = 1) -> Side {
    let (x, y, z) = self.to_coords()

    let x2 = 0 * x + c * -1 * y + 0 * z
    let y2 = c * 1 * x + 0 * y + 0 * z
    let z2 = 0 * x + 0 * y + 1 * z
    return to_side(t: (x2, y2, z2))
  }

  func to_opposite() -> Side {
    switch self {
    case .Face: return .Back
    case .Back: return .Face
    case .Right: return .Left
    case .Left: return .Right
    case .Top: return .Under
    case .Under: return .Top
    }
  }
}

extension Side: CustomStringConvertible {
  var description: String {
    switch self {
    case .Face: return "F"
    case .Back: return "B"
    case .Under: return "U"
    case .Top: return "T"
    case .Left: return "L"
    case .Right: return "R"
    }
  }
}

struct Sides {
  var above: Side
  var below: Side
  var front: Side
  var behind: Side
  var righty: Side
  var lefty: Side
}

struct Cube {
  var above: Side
  var front: Side
  var righty: Side
  let box_size: Int

  func get_sides() -> Sides {
    Sides(
      above: above, below: above.to_opposite(),
      front: front, behind: front.to_opposite(),
      righty: righty, lefty: righty.to_opposite()
    )
  }

  init(_ box_size: Int) {
    self.front = .Face
    self.above = .Top
    self.righty = .Right
    self.box_size = box_size
  }

  mutating func spin_cube_direction(d: Direction, s: Side) {
    while get_direction_side(dir: d) != s {
      spin()
    }
  }

  func get_direction_side(dir: Direction) -> Side {
    let sides = get_sides()
    switch dir {
    case .West: return sides.lefty
    case .East: return sides.righty
    case .North: return sides.above
    case .South: return sides.below
    }
  }

  func get_side_direction(side: Side) -> Direction? {
    let sides = get_sides()
    if side == sides.lefty {
      return .some(.West)
    } else if side == sides.righty {
      return .some(.East)
    } else if side == sides.above {
      return .some(.North)
    } else if side == sides.below {
      return .some(.South)
    } else {
      return .none
    }
  }

  func print_sides() {
    print("Front: \(front)")
    print("               Above: \(above)")
    print("               Right: \(righty)\n")

  }

  mutating func travel(direction: Direction) {
    switch direction {
    case .South: self.pitch(away: true)
    case .East: self.turn(clockwise: true)
    case .West: self.turn(clockwise: false)
    case .North: self.pitch(away: false)
    }
  }

  mutating func undo_travel(direction: Direction) {
    switch direction {
    case .South: self.pitch(away: false)
    case .East: self.turn(clockwise: false)
    case .West: self.turn(clockwise: true)
    case .North: self.pitch(away: true)
    }
  }

  mutating func spin(clockwise: Bool = true) {
    let c = clockwise ? 1 : -1
    switch front {
    case .Face:
      righty = righty.rotate_z(c)
      above = above.rotate_z(c)
    case .Back:
      righty = righty.rotate_z(-c)
      above = above.rotate_z(-c)
    case .Right:
      righty = righty.rotate_x(c)
      above = above.rotate_x(c)
    case .Left:
      righty = righty.rotate_x(-c)
      above = above.rotate_x(-c)
    case .Top:
      righty = righty.rotate_y(c)
      above = above.rotate_y(c)
    case .Under:
      righty = righty.rotate_y(-c)
      above = above.rotate_y(-c)
    }
  }

  mutating func turn(clockwise: Bool = true) {
    let c = clockwise ? 1 : -1

    switch above {
    case .Top:
      front = front.rotate_y(c)
      righty = righty.rotate_y(c)
    case .Under:
      front = front.rotate_y(-c)
      righty = righty.rotate_y(-c)
    case .Right:
      front = front.rotate_x(c)
      righty = righty.rotate_x(c)
    case .Left:
      front = front.rotate_x(-c)
      righty = righty.rotate_x(-c)
    case .Face:
      front = front.rotate_z(c)
      righty = righty.rotate_z(c)
    case .Back:
      front = front.rotate_z(-c)
      righty = righty.rotate_z(-c)

    }
  }

  mutating func pitch(away: Bool = true) {
    let c = away ? 1 : -1

    switch righty {
    case .Top:
      front = front.rotate_y(c)
      above = above.rotate_y(c)
    case .Under:
      front = front.rotate_y(-c)
      above = above.rotate_y(-c)
    case .Right:
      front = front.rotate_x(c)
      above = above.rotate_x(c)
    case .Left:
      front = front.rotate_x(-c)
      above = above.rotate_x(-c)
    case .Face:
      front = front.rotate_z(c)
      above = above.rotate_z(c)
    case .Back:
      front = front.rotate_z(-c)
      above = above.rotate_z(-c)

    }
  }
}

enum Tile: Equatable {
  case void
  case wall
  case free
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

  func to_opposite() -> Direction {
    switch self {
    case .East: return .West
    case .West: return .East
    case .North: return .South
    case .South: return .North
    }
  }
}

class Simulation {
  var row: Int
  var col: Int
  var dir: Direction
  var board: [[Tile]]
  let max_r: Int
  let max_c: Int
  let box_size: Int
  var cube: Cube
  var blocks = [[Block]]()
  var side_block_map = [Side: Coord]()
  var last_side: Side = .Face

  init(the_board: [[Tile]]) {
    board = the_board
    row = 1
    col = board[row].firstIndex(of: .free)!
    dir = Direction.East
    max_c = board[0].count - 1
    max_r = board.count - 1

    if (board.count - 2) % 50 == 0 {
      box_size = 50
    } else {
      box_size = 4
    }
    self.cube = Cube(box_size)

    for r in stride(from: 1, to: max_r, by: box_size) {
      var tmp_row = [Block]()
      for c in stride(from: 1, to: max_c, by: box_size) {
        if case .void = board[r][c] {
          tmp_row.append(.Empty)
        } else {
          tmp_row.append(.Filled(.none))
        }
      }
      blocks.append(tmp_row)
    }

    let current_r = 0
    let current_c = col / box_size
    blocks[current_r][current_c].set_side(s: .Face)

    side_block_map[.Face] = Coord(row: current_r, col: current_c)
    explore_map(current_r, current_c)
    print_block_map()
  }

  func print_block_map() {
    for row in blocks {
      for b in row {
        print(b, terminator: "")
      }
      print("")
    }
    print("\n")
  }

  func valid_searches(_ row: Int, _ col: Int) -> [(Direction, Int, Int)] {
    let num_rows = blocks.count
    let num_cols = blocks[0].count

    return [(Direction.East, 0, 1), (.West, 0, -1), (.North, -1, 0), (.South, 1, 0)]
      .map({ (d, r, c) in (d, row + r, col + c) })
      .filter({ (d, r, c) in 0 <= r && r < num_rows && 0 <= c && c < num_cols })
  }

  func explore_map(_ curr_r: Int, _ curr_c: Int) {
    let searches = valid_searches(curr_r, curr_c)

    for (d, r, c) in searches {
      if case .Filled(.none) = blocks[r][c] {
        cube.travel(direction: d)
        blocks[r][c].set_side(s: cube.front)
        side_block_map[cube.front] = Coord(row: r, col: c)
        explore_map(r, c)
        cube.undo_travel(direction: d)
      }
    }
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

    case .Move(let d): move(d)
    }
  }

  func move(_ d: Int) {
    if d == 0 { return }

    var r = row
    var c = col

    switch dir {
    case .East: c += 1
    case .West: c -= 1
    case .North: r -= 1
    case .South: r += 1
    }

    switch board[r][c] {
    case .wall: return
    case .free:

      if (dir == .East && c % box_size == 1 && col % box_size != 1)
        || (dir == .South && r % box_size == 1 && row % box_size != 1)
        || (dir == .West && c % box_size == 0 && col % box_size != 0)
        || (dir == .North && r % box_size == 0 && row % box_size != 0)
      {
        last_side = cube.front
        cube.travel(direction: dir)
      }

      row = r
      col = c

      return move(d - 1)
    case .void:
      let old_cube = cube

      last_side = cube.front
      cube.travel(direction: dir)

      let block_coords = side_block_map[cube.front]!
      let searches = valid_searches(block_coords.row, block_coords.col)

      for (search_dir, br, bc) in searches {
        if case .Filled(.some(let adj_side)) = blocks[br][bc] {
          cube.spin_cube_direction(d: search_dir, s: adj_side)

          if case .some(let from_dir) = cube.get_side_direction(side: last_side) {

            var offset = row
            if dir == .North || dir == .South {
              offset = col
            }

            let test = get_coords(from_dir, dir, coords: block_coords, at: offset)

            if case .free = board[test.row][test.col] {
              dir = from_dir.to_opposite()
              row = test.row
              col = test.col

              return move(d - 1)
            } else {
              self.cube = old_cube
              return
            }
          }
          break
        }
      }
      return move(d - 1)
    }
  }

  func get_coords(_ from_dir: Direction, _ to_dir: Direction, coords: Coord, at: Int) -> Coord {

    // SS NN EE WW NE SW => Anti
    // NW SE NS EW => Correlated

    var correlated: Bool
    switch (from_dir, to_dir) {
    case (.North, .North), (.South, .South), (.East, .East), (.West, .West): correlated = false
    case (.North, .East), (.East, .North), (.South, .West), (.West, .South): correlated = false
    default: correlated = true
    }

    let b = box_size
    let cc = coords.col  // 0 based
    let cr = coords.row  // 0 based
    var offset: Int
    if correlated {
      offset = (at - 1) % b + 1
    } else {
      offset = b - ((at - 1) % b)
    }

    switch from_dir {
    case .North: return Coord(row: (cr * b) + 1, col: (cc * b) + offset)
    case .South: return Coord(row: (cr * b) + b, col: (cc * b) + offset)
    case .East: return Coord(row: (cr * b) + offset, col: (cc * b) + b)
    case .West: return Coord(row: (cr * b) + offset, col: (cc * b) + 1)
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
    line.map({ c in
      switch c {
      case ".": return Tile.free
      case "#": return Tile.wall
      default: return Tile.void
      }
    })
  })
)

sim.print_coords()
for c in commands {
  print(c)
  sim.do_command(cmd: c)
  sim.print_coords()
}

sim.print_password()
