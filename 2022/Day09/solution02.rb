#!/usr/bin/env ruby
# Sam Shepard - 2022
# First time ruby!

class Point
    @x = 0
    @y = 0

    def Up(d)
        @y += d
    end

    def Down(d)
        @y -= d
    end

    def Left(d)
        @x -= d
    end

    def Right(d)
        @x += d
    end

    def initialize
        @x = 0
        @y = 0
    end

    def to_s
        "(#{@x}, #{@y})"
    end

    def x
        @x
    end

    def y
        @y
    end

    def distance(other)
        [(self.x - other.x).abs, (self.y - other.y).abs].max
    end

    def Follow(other)
        if self.distance(other) > 1
            xd = (other.x - self.x)
            yd = (other.y - self.y)

            if xd.abs > 0
                @x += xd / xd.abs
            end

            if yd.abs > 0
                @y += yd / yd.abs
            end
        end
    end
end


if ARGV.length != 1
    puts "Need file path input"
end

data = File.read(ARGV[0]).split("\n")

points = Array.new(10) { |v| Point.new }

visited = Hash.new
visited[points[9].to_s] = 1

for command in data
    dir, movement = command.split(" ")
    movement = movement.to_i

    while movement > 0 
        case dir
        when "U"
            points[0].Up(1)
        when "D"
            points[0].Down(1)
        when "L"
            points[0].Left(1)
        when "R"
            points[0].Right(1)
        end

        for i in 1..9
            points[i].Follow(points[i-1])
        end
        visited[points[9].to_s] = 1
        movement -= 1
    end
    
end 

puts visited.length