// Sam Shepard - 2022
// To compile: g++ -o solution01 solution01.cpp -std=c++20

#include <string>
#include <fstream>
#include <iostream>
#include <vector>

class Point
{
public:
    size_t row;
    size_t col;
    Point(size_t r, size_t c)
    {
        row = r;
        col = c;
    }

    Point()
    {
        row = 0;
        col = 0;
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
}