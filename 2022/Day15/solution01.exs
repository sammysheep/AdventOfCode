# Sam Shepard - 2022
# First-time Elixir!

require Logger

{filename, find_row} =
  if arg = System.argv() |> Enum.at(0) do
    {arg, 2_000_000}
  else
    {"test.txt", 10}
  end

data =
  File.read(filename)
  |> elem(1)
  |> String.split("\n")
  |> Enum.filter(fn x -> String.length(x) != 0 end)
  |> Enum.map(fn s ->
    [_ | tail] = Regex.run(~r{x=(-?\d+), y=(-?\d+).+?x=(-?\d+), y=(-?\d+)}, s)
    Enum.map(tail, fn i -> String.to_integer(i) end)
  end)

data |> inspect(pretty: true) |> Logger.debug()

beacons =
  data |> Enum.map(fn [_, _, x, y] -> [x, y] end) |> Enum.filter(fn [_, y] -> y == find_row end)

beacons |> inspect(pretty: true, charlists: :as_lists) |> Logger.debug()

data |> inspect(pretty: true) |> Logger.debug()

defmodule Sol do
  def manh_dist([x1, y1, x2, y2]) do
    abs(x2 - x1) + abs(y2 - y1)
  end

  # Only draw on the needed target row
  def make_line([sx, sy, bx, by], ty) do
    search_distance = abs(sx - bx) + abs(sy - by)
    vertical_distance = abs(ty - sy)

    if vertical_distance > search_distance do
      []
    else
      flanking = search_distance - vertical_distance
      for x <- (sx - flanking)..(sx + flanking), do: [x, ty]
    end
  end

  # +3    3
  # +2   323
  # +1  32123
  #  0 3210123
  # -1  32123
  # -2   323
  # -3    3

  # Exhaustive filling too resource intensive and wasteful
  def make_diamond([sx, sy, bx, by]) do
    d = abs(sx - bx) + abs(sy - by)
    make_band(sx, sy, d, 0)
  end

  def make_band(sx, sy, d, inc) do
    if d >= 0 do
      if inc == 0 do
        band = for x <- (sx - d)..(sx + d), do: [x, sy]
        above = make_band(sx, sy, d - 1, +1)
        below = make_band(sx, sy, d - 1, -1)

        above ++ band ++ below
      else
        if inc > 0 do
          band = for x <- (sx - d)..(sx + d), do: [x, sy + inc]
          above = make_band(sx, sy, d - 1, inc + 1)

          if above != nil do
            band ++ above
          else
            band
          end
        else
          # inc < 0
          band = for x <- (sx - d)..(sx + d), do: [x, sy + inc]
          below = make_band(sx, sy, d - 1, inc - 1)

          if below != nil do
            band ++ below
          else
            band
          end
        end
      end
    end
  end
end

sets =
  data
  |> Enum.map(fn row ->
    Sol.make_line(row, find_row)
    |> Enum.filter(fn [_, y] -> y == find_row end)
    |> Enum.map(fn [x, _] -> x end)
  end)
  |> Enum.filter(fn x -> length(x) > 0 end)
  |> Enum.map(fn row -> MapSet.new(row) end)

sets |> inspect(pretty: true, charlists: :as_lists) |> Logger.debug()

coords_found = Enum.reduce(sets, MapSet.new(), fn acc, i -> MapSet.union(acc, i) end)

beacons_in_row = MapSet.size(MapSet.new(beacons))
count_found = MapSet.size(coords_found) - beacons_in_row

IO.puts("Found #{count_found} in y = #{find_row}")
