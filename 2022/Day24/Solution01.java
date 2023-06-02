import java.nio.file.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;

enum Direction {
    EAST,
    SOUTH,
    WEST,
    NORTH,
    NONE
}

record TimePlace(int round, Coord spot) {
}

record Coord(int row, int col) {
}

class Blizzard {
    public static int row_mod = 0;
    public static int col_mod = 0;

    Direction dir = Direction.NONE;
    int row = 0;
    int col = 0;

    Blizzard(Direction d, int r, int c) {
        this.dir = d;
        this.row = r;
        this.col = c;
    }

    Blizzard() {
    }

    public Coord get_position(int round) {
        return switch (dir) {
            case EAST -> new Coord(row, (round + col - 1) % col_mod + 1);
            case WEST -> new Coord(row, col_mod - ((round - col + col_mod) % col_mod));
            case SOUTH -> new Coord((round + row - 1) % row_mod + 1, col);
            case NORTH -> new Coord(row_mod - ((round - row + row_mod) % row_mod), col);
            default -> new Coord(row, col);
        };
    }

}

public class Solution01 {
    static int nrows = 0;
    static int ncols = 0;
    static int repeat_mod = 0;
    static Coord start;
    static Coord end;
    static boolean[][][] filled;
    static final Coord[] moves = {
            new Coord(0, 1), // E
            new Coord(1, 0), // S
            new Coord(0, 0), // -
            new Coord(-1, 0), // N
            new Coord(0, -1) // W
    };
    static int fastest = Integer.MAX_VALUE;
    static HashSet<TimePlace> visited = new HashSet<TimePlace>();

    public static void main(String args[]) {
        var filename = "test.txt";
        if (args.length > 0) {
            filename = args[0];
        }

        var data = new String[0];
        try {
            data = Files.readString(Paths.get(filename)).split("\n");
        } catch (IOException e) {
            System.out.println("Failed: " + e);
            System.exit(1);
        }

        nrows = data.length;
        ncols = data[0].length();
        repeat_mod = nrows * ncols;
        start = new Coord(0, 1);
        end = new Coord(nrows - 1, ncols - 2);

        Blizzard.row_mod = nrows - 2;
        Blizzard.col_mod = ncols - 2;

        ArrayList<Blizzard> blizzards = new ArrayList<Blizzard>();
        for (int row = 0; row < data.length; row++) {
            for (int col = 0; col < data[row].length(); col++) {
                switch (data[row].charAt(col)) {
                    case '<':
                        blizzards.add(new Blizzard(Direction.WEST, row, col));
                        break;
                    case '>':
                        blizzards.add(new Blizzard(Direction.EAST, row, col));
                        break;
                    case 'v':
                        blizzards.add(new Blizzard(Direction.SOUTH, row, col));
                        break;
                    case '^':
                        blizzards.add(new Blizzard(Direction.NORTH, row, col));
                        break;
                }
            }
        }

        filled = new boolean[repeat_mod][nrows][ncols];
        for (int r = 0; r < repeat_mod; r++) {
            // Fill sides, default to false
            for (int row = 0; row < nrows; row++) {
                filled[r][row][0] = true;
                filled[r][row][ncols - 1] = true;
            }

            // Fill top/bottom
            for (int col = 1; col < ncols - 1; col++) {
                filled[r][0][col] = true;
                filled[r][nrows - 1][col] = true;
            }

            // Unfill start and stop
            filled[r][start.row()][start.col()] = false;
            filled[r][end.row()][end.col()] = false;

            for (var b : blizzards) {
                var blizz = b.get_position(r);
                filled[r][blizz.row()][blizz.col()] = true;
            }

        }

        System.out.println("Board was: " + nrows + " x " + ncols);

        Coord current = start;
        var best = search(0, current);

        System.out.println("The best time was " + best + " minutes");

    }

    static int search(int round, Coord current) {
        int r = (round + 1) % repeat_mod;
        var next = round + 1;
        int minutes = Integer.MAX_VALUE;

        var key = new TimePlace(round, current);
        if (visited.contains(key)) {
            return minutes;
        } else {
            visited.add(key);
        }

        if (round > fastest) {
            return minutes;
        }

        for (var dir : moves) {
            var move = new Coord(current.row() + dir.row(), current.col() + dir.col());
            if (move.row() < 0
                    || move.row() >= nrows
                    || move.col() < 0
                    || move.col() >= ncols
                    || filled[r][move.row()][move.col()]) {
                continue;
            }

            if (end.row() == move.row() && end.col() == move.col()) {

                if (next < fastest) {
                    fastest = next;
                }
                return next;
            }

            var found = search(next, move);
            if (found < minutes) {
                minutes = found;
            }
        }

        return minutes;
    }

    void print_filled(int r) {
        System.out.println("r: " + r);

        for (int row = 0; row < nrows; row++) {
            for (int col = 0; col < ncols; col++) {
                if (filled[r][row][col]) {
                    System.out.print("X");
                } else {
                    System.out.print(".");
                }
            }
            System.out.println("");
        }
        System.out.println("");
    }
}
