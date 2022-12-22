// Sam Shepard - 2022
// To compile: g++ -o solution01 solution01.cpp -std=c++20
//
// Based on Dijkstra's algorithm in C++ using a min priority queue and grid.
// Too slow and memory inefficient. :/

#include <string>
#include <fstream>
#include <iostream>
#include <vector>
#include <queue>

class Point
{
public:
    int row;
    int32_t col;
    size_t steps = 0;

    Point(int r, int c)
    {
        row = r;
        col = c;
    }

    Point()
    {
        row = 0;
        col = 0;
    }

    Point(Point &p, int r, int c)
    {
        steps = p.steps + 1;
        row = p.row + r;
        col = p.col + c;
    }

    bool operator<(const Point &p) const
    {
        return steps < p.steps;
    }
    bool operator>(const Point &p) const
    {
        return steps > p.steps;
    }

    bool operator==(const Point &p) const
    {
        return row == p.row && col == p.col;
    }

    bool operator!=(const Point &p) const
    {
        return row != p.row || col != p.col;
    }
};

std::ostream &operator<<(std::ostream &os, const Point &p)
{
    return os << "(" << p.row << ", " << p.col << ") @ " << p.steps;
}

class Grid
{

public:
    size_t nrows;
    size_t ncols;
    std::vector<std::vector<bool>> unvisited;
    std::vector<std::vector<uint8_t>> grid;
    std::priority_queue<Point, std::vector<Point>, std::greater<Point>> active;

    Grid(size_t R, size_t C, std::vector<std::vector<uint8_t>> &G)
    {
        nrows = R;
        ncols = C;
        unvisited = std::vector<std::vector<bool>>(nrows, std::vector<bool>(ncols, true));
        grid = G;
    }

    void add_point(Point p)
    {
        active.emplace(p);
    }

    bool valid_move(Point &from, Point &to)
    {
        if (to.row >= nrows || to.row < 0 || to.col < 0 || to.col >= ncols)
        {
            return false;
        }
        else if (!unvisited[to.row][to.col] || (grid[to.row][to.col] - grid[from.row][from.col]) > 1)
        {
            return false;
        }
        else
        {
            return true;
        }
    }

    Point search_and_add()
    {
        Point p;

        // do search
        if (active.size() > 0)
        {
            p = active.top();
            active.pop();
            unvisited[p.row][p.col] = false;

            int old_size = active.size();

            Point up = Point(p, +1, 0);
            Point down = Point(p, -1, 0);
            Point left = Point(p, 0, -1);
            Point right = Point(p, 0, +1);

            if (valid_move(p, up))
            {
                add_point(up);
            }

            if (valid_move(p, down))
            {
                add_point(down);
            }

            if (valid_move(p, left))
            {
                add_point(left);
            }

            if (valid_move(p, right))
            {
                add_point(right);
            }
        }

        return p;
    }
};

int main(int argc, char *argv[])
{

    std::string filename = "test.txt";
    if (argc > 1)
    {
        filename = std::string(argv[1]);
    }

    std::vector<std::vector<uint8_t>> grid;
    Point start, end;
    size_t nrow = 0;
    size_t ncol = 0;

    std::ifstream file(filename);
    if (file.is_open())
    {
        std::string line;
        while (std::getline(file, line))
        {
            std::vector<uint8_t> vbuff(line.begin(), line.end());
            grid.push_back(vbuff);

            std::size_t col_start = line.find_first_of("S");
            if (col_start != std::string::npos)
            {
                start = Point(nrow, col_start);
                grid[nrow][col_start] = 'a';
                ncol = line.size();
            }

            std::size_t col_end = line.find_first_of("E");
            if (col_end != std::string::npos)
            {
                end = Point(nrow, col_end);
                grid[nrow][col_end] = 'z';
            }

            nrow++;
        }
    }
    else
    {
        std::cerr << "Bad filename.\n";
        exit(1);
    }
    file.close();

    std::cout << "Grid of " << nrow << " rows by " << ncol << " cols\n";
    std::cout << "Start (row, col) at (" << start.row << ", " << start.col << ")\n";
    std::cout << "End   (row, col) at (" << end.row << ", " << end.col << ")\n";

    Grid g = Grid(nrow, ncol, grid);
    g.add_point(start);

    Point p;
    size_t step = 0;
    do
    {
        p = g.search_and_add();
        if (p.steps > step)
        {
            step = p.steps;
            std::cout << "Step " << p.steps << "\n";
        }
    } while (p != end);

    std::cout << "\n"
              << p << "\n";
}