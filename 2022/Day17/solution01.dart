// Sam Shepard - 2023
// First time dart!

import "dart:io";

void main(List<String> arguments) {
  var filename = "test.txt";
  if (arguments.length > 0) {
    filename = arguments[0];
  }

  var jets = File(filename)
      .readAsStringSync()
      .trim()
      .split('')
      .map((e) => e == '<' ? Direction.left : Direction.right);

  var sim = new Simulation();

  resetLoop:
  while (true) {
    for (var direction in jets) {
      sim.move_shapes(direction);
      sim.move_shapes(Direction.down);
      if (sim.numberShapesCompleted == 2022) {
        break resetLoop;
      }
    }
  }

  print("The height is: ${sim.topFilledRow}");
}

typedef Shaft = List<List<Fill>>;

class Simulation {
  static Shaft grid = [List.filled(9, Fill.immovable)];
  static int top_filled_row = 0;
  static int shapes_completed = 0;
  static const List<ShapeType> shapes = [
    ShapeType.hline,
    ShapeType.plus,
    ShapeType.bracket,
    ShapeType.vline,
    ShapeType.square
  ];
  Shape cursor = new HLine(Position(0, 0));

  int get topFilledRow {
    return top_filled_row;
  }

  int get numberShapesCompleted {
    return shapes_completed;
  }

  void addRow() {
    grid.add(List.generate(
        9, (index) => index % 8 == 0 ? Fill.immovable : Fill.empty));
  }

  void stopRocks() {
    cursor.get_coords().forEach((p) {
      grid[p.row][p.col] = Fill.immovable;
      if (p.row > top_filled_row) {
        top_filled_row = p.row;
      }
    });
  }

  void nextShape() {
    shapes_completed++;
    addShapeTypeToTop(shapes[shapes_completed % shapes.length]);
  }

  int getShapeTypeHeight(ShapeType shape) {
    switch (shape) {
      case ShapeType.hline:
        return 1;
      case ShapeType.plus:
        return 3;
      case ShapeType.bracket:
        return 3;
      case ShapeType.vline:
        return 4;
      case ShapeType.square:
        return 2;
    }
  }

  void addShapeTypeToTop(ShapeType shape) {
    int bottom_index = top_filled_row + 4;
    int top_index = bottom_index + getShapeTypeHeight(shape) - 1;
    if (grid.length - 1 < top_index) {
      int missing = top_index - (grid.length - 1);
      while (missing > 0) {
        addRow();
        missing--;
      }
    }

    switch (shape) {
      case ShapeType.hline:
        this.cursor = HLine(Position(top_index, 3));
        break;
      case ShapeType.plus:
        this.cursor = Plus(Position(top_index, 4));
        break;
      case ShapeType.bracket:
        this.cursor = Bracket(Position(top_index, 5));
        break;
      case ShapeType.vline:
        this.cursor = VLine(Position(top_index, 3));
        break;
      case ShapeType.square:
        this.cursor = Square(Position(top_index, 3));
        break;
    }
  }

  void printGrid() {
    Shaft shaft = [
      for (var row in grid) [...row]
    ];

    //print(cursor
    //    .get_coords()
    //    .map((e) => e.row.toString() + " " + e.col.toString()));
    cursor.get_coords().forEach((p) {
      shaft[p.row][p.col] = Fill.rock;
    });

    for (List<Fill> row in shaft.reversed) {
      for (Fill block in row) {
        stdout.write(block.toString());
      }
      print("");
    }
  }

  void move_shapes(Direction d) {
    Shape test = cursor.copyWith();
    test.move(d);

    bool is_valid = test.get_coords().every((p) =>
        p.col > 0 &&
        p.col < 8 &&
        p.row > 0 &&
        p.row < grid.length &&
        grid[p.row][p.col] == Fill.empty);
    if (is_valid) {
      cursor = test.copyWith();
    } else if (d == Direction.down) {
      stopRocks();
      nextShape();
    }
  }

  Simulation() {
    addShapeTypeToTop(ShapeType.hline);
  }
}

enum Fill {
  immovable("#"),
  rock("@"),
  empty(".");

  factory Fill.fromString(String s) {
    if (s == "@") {
      return Fill.rock;
    } else if (s == "#") {
      return Fill.immovable;
    } else {
      return Fill.empty;
    }
  }
  const Fill(this.value);
  final String value;
  @override
  String toString() => this.value;
}

class Position {
  int row = 0;
  int col = 0;
  Position(this.row, this.col);
}

abstract class Shape {
  Position handle = Position(0, 0);

  Shape(Position this.handle);
  Shape copyWith();
  List<Position> get_coords();

  void move(Direction d) {
    switch (d) {
      case Direction.left:
        this.handle.col--;
        break;
      case Direction.right:
        this.handle.col++;
        break;
      case Direction.up:
        this.handle.row++;
        break;
      case Direction.down:
        this.handle.row--;
        break;
    }
  }
}

class HLine extends Shape {
  List<Position> get_coords() {
    return [
      for (var i = 0; i < 4; i++) Position(this.handle.row, this.handle.col + i)
    ];
  }

  Shape copyWith() {
    return HLine(Position(this.handle.row, this.handle.col));
  }

  HLine(Position p) : super(p);
}

class VLine extends Shape {
  List<Position> get_coords() {
    return [
      for (var i = 0; i < 4; i++) Position(this.handle.row - i, this.handle.col)
    ];
  }

  Shape copyWith() {
    return VLine(Position(this.handle.row, this.handle.col));
  }

  VLine(Position p) : super(p);
}

class Square extends Shape {
  List<Position> get_coords() {
    return [
      for (var i = 0; i < 2; i++)
        for (var j = 0; j < 2; j++)
          Position(this.handle.row - i, this.handle.col + j)
    ];
  }

  Shape copyWith() {
    return Square(Position(this.handle.row, this.handle.col));
  }

  Square(Position p) : super(p);
}

class Plus extends Shape {
  List<Position> get_coords() {
    return [
      this.handle,
      Position(this.handle.row - 1, this.handle.col - 1),
      Position(this.handle.row - 1, this.handle.col),
      Position(this.handle.row - 1, this.handle.col + 1),
      Position(this.handle.row - 2, this.handle.col),
    ];
  }

  Shape copyWith() {
    return Plus(Position(this.handle.row, this.handle.col));
  }

  Plus(Position p) : super(p);
}

class Bracket extends Shape {
  List<Position> get_coords() {
    return [
      this.handle,
      Position(this.handle.row - 1, this.handle.col),
      Position(this.handle.row - 2, this.handle.col),
      Position(this.handle.row - 2, this.handle.col - 1),
      Position(this.handle.row - 2, this.handle.col - 2),
    ];
  }

  Shape copyWith() {
    return Bracket(Position(this.handle.row, this.handle.col));
  }

  Bracket(Position p) : super(p);
}

enum Direction {
  left('<'),
  right('>'),
  up('v'),
  down('^');

  const Direction(this.value);
  final String value;
}

enum ShapeType { hline, plus, bracket, vline, square }
