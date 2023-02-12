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
head = Point.new
tail = Point.new
visited = Hash.new
visited[tail.to_s] = 1

for command in data
    dir, movement = command.split(" ")
    movement = movement.to_i

    while movement > 0 
        case dir
        when "U"
            head.Up(1)
        when "D"
            head.Down(1)
        when "L"
            head.Left(1)
        when "R"
            head.Right(1)
        end
        tail.Follow(head)
        visited[tail.to_s] = 1
        movement -= 1
    end
    
end 

puts head
puts tail
puts visited.length