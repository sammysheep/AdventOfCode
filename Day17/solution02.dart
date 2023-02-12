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
      .map((e) => e == '<' ? Direction.left : Direction.right)
      .toList();

  // The target number, batch size, and number of batches could have been taken
  // as arguments. The maximum simulated sample is batch_size * number_batches.
  const int target_number = 1000000000000;
  const int batch_size = 1000;
  const int number_batches = 100;

  // Yes, I tested this first using Perl...like a gentleman! Perhaps one could
  // do a non-overlapping longest repeated substring implementation using a
  // suffix tree, but not for a bunch of overly cautious elephants!
  var detect_cycle = new RegExp(r"(\d+?)\1{2,}$");
  bool cycle_found = false;
  List<int> cycle = [];

  var sim = new Simulation(jets);
  var sample = sim.run(batch_size);
  for (var _ in sample.take(number_batches)) {
    var match = detect_cycle.firstMatch(sim.getSeriesSample().join(""));

    if (match != null) {
      int start = match.start;
      int length = match.group(1)!.length;
      cycle = sim.getSeriesSample().sublist(start, start + length);
      cycle_found = true;

      break;
    }
  }

  var total_height = 0;
  if (target_number <= sim.numberShapesCompleted) {
    total_height =
        sim.getSeriesSample().take(target_number).reduce((a, b) => a + b);

    print("The simulated height is: ${total_height}");
  } else if (cycle_found) {
    int cycle_height = cycle.reduce((a, b) => a + b);
    int remaining = (target_number - sim.numberShapesCompleted);

    total_height = sim.getSeriesSample().reduce((a, b) => a + b) +
        (remaining ~/ cycle.length) * cycle_height +
        cycle.take(remaining % cycle.length).reduce((a, b) => a + b);

    print("The estimated height is: ${total_height}");
  } else {
    print(
        "No cycle found but needed for a height estimate. Try adjusting the maximum sample.");
  }
}

typedef Shaft = List<List<Fill>>;

class Simulation {
  Shaft grid = [List.filled(9, Fill.immovable)];
  int top_filled_row = 0;
  int shapes_completed = 0;
  static const List<ShapeType> shapes = [
    ShapeType.hline,
    ShapeType.plus,
    ShapeType.bracket,
    ShapeType.vline,
    ShapeType.square
  ];
  Shape cursor = new HLine(Position(0, 0));
  List<int> series = [];
  List<Direction> jets = [];

  List<int> getSeriesSample() {
    return series;
  }

  int get topFilledRow {
    return top_filled_row;
  }

  int get numberShapesCompleted {
    return shapes_completed;
  }

  Iterable run(int batch_size) sync* {
    int previous = 0;
    while (true) {
      for (var direction in jets) {
        this.move_shapes(direction);
        this.move_shapes(Direction.down);

        if (this.shapes_completed % batch_size == 0 &&
            this.shapes_completed > previous) {
          previous = this.shapes_completed;
          yield this.shapes_completed;
        }
      }
    }
  }

  void addRow() {
    grid.add(List.generate(
        9, (index) => index % 8 == 0 ? Fill.immovable : Fill.empty));
  }

  void stopRocks() {
    int prev = top_filled_row;
    cursor.get_coords().forEach((p) {
      grid[p.row][p.col] = Fill.immovable;
      if (p.row > top_filled_row) {
        top_filled_row = p.row;
      }
    });
    series.add(top_filled_row - prev);
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

  Simulation(List<Direction> jets) {
    this.jets = jets;
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
