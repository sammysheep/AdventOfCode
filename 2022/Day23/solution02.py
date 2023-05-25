#!/usr/bin/env python3
# Sam Shepard - 2023
#
# I rarely Python, but when I do, I want 3.10+

from sys import version_info as v, stderr, exit, argv
from pathlib import Path
from enum import Enum, unique
from dataclasses import dataclass

debug = False
rounds = 10000

if v[0] < 3 or v[1] < 10:
    print("Python 3.10+ required", file=stderr)
    exit(1)


@dataclass(eq=True, frozen=True)
class Coord:
    row: int = 0
    col: int = 0

    def __add__(self, o):
        return Coord(self.row + o.row, self.col + o.col)

    def __str__(self):
        return f"({self.row}, {self.col})"


@unique
class Direction(Enum):
    North = Coord(-1, 0)
    NorthEast = Coord(-1, 1)
    East = Coord(0, 1)
    SouthEast = Coord(1, 1)
    South = Coord(1, 0)
    SouthWest = Coord(1, -1)
    West = Coord(0, -1)
    NorthWest = Coord(-1, -1)


filename = "test.txt"
if len(argv) > 1:
    filename = argv[1]

positions = dict()
data = Path(filename).read_text().split("\n")
for row, line in enumerate(data):
    for col, char in enumerate(line):
        if char == "#":
            positions[Coord(row, col)] = True


def make_checker(directions):
    def check_direction(c):
        return not any(((d.value + c) in positions for d in directions))

    return check_direction


def isolated_position(c):
    return not any(((d.value + c) in positions for d in Direction))


direction_checkers = (
    make_checker((Direction.NorthWest, Direction.North, Direction.NorthEast)),
    make_checker((Direction.SouthWest, Direction.South, Direction.SouthEast)),
    make_checker((Direction.NorthWest, Direction.West, Direction.SouthWest)),
    make_checker((Direction.NorthEast, Direction.East, Direction.SouthEast)),
)


def new_coord(c, i):
    match i:
        case 0:
            return c + Direction.North.value
        case 1:
            return c + Direction.South.value
        case 2:
            return c + Direction.West.value
        case 3:
            return c + Direction.East.value
        case _:
            print(f"Unexpected state: {i}")
            return c


def search(c, round):
    r = (round - 1) % 4
    for i in map(lambda x: x % 4, range(r, r + 4)):
        if direction_checkers[i](c):
            return new_coord(c, i)
    return c


moved = len(positions)
round = 1
while moved > 0:
    moves = dict()
    moved = 0

    if debug:
        print(f"Round: {round}")

    for current in positions.keys():
        if isolated_position(current):
            moves[current] = [current]
            continue

        proposed = search(current, round)

        if moves.get(proposed) == None:
            moves[proposed] = []

        moves[proposed] += [current]
        if proposed != current:
            moved += 1

        if debug:
            if proposed != current:
                print("*", end="")
            print(f"{current} -> {proposed}")

    positions = dict()
    for proposed in moves.keys():
        # Only one requested to move to this location
        if len(moves[proposed]) == 1:
            positions[proposed] = True
        # Collisions required to stay in place
        else:
            moved -= len(moves[proposed])
            for old_positions in moves[proposed]:
                positions[old_positions] = True

    print(f"Round {round}, {moved} elves moved")
    round += 1
