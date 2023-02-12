# Sam Shepard - 2022
# First-time Elixir!

require Logger

{filename, upper_bound} =
  if arg = System.argv() |> Enum.at(0) do
    {arg, 4_000_000}
  else
    {"test.txt", 20}
  end

lower_bound = 0

data =
  File.read(filename)
  |> elem(1)
  |> String.split("\n")
  |> Enum.filter(fn x -> String.length(x) != 0 end)
  |> Enum.map(fn s ->
    [_ | tail] = Regex.run(~r{x=(-?\d+), y=(-?\d+).+?x=(-?\d+), y=(-?\d+)}, s)
    Enum.map(tail, fn i -> String.to_integer(i) end)
  end)
  |> Enum.map(fn [sx, sy, bx, by] -> [sx, sy, abs(sx - bx) + abs(sy - by)] end)

defmodule Sol do
  # Only draw on the needed target row
  def make_line([sx, sy, search_distance], ty) do
    vertical_distance = abs(ty - sy)

    if vertical_distance > search_distance do
      nil
    else
      flanking = search_distance - vertical_distance
      # Ranges are orders of mangitude faster than using MapSet.
      # Of course, there are likely other areas left unoptimized but at least
      # now it is tractable.
      max(unquote(lower_bound), sx - flanking)..min(unquote(upper_bound), sx + flanking)
    end
  end

  def find_empty_coords(data, find_row) do
    ranges =
      data
      |> Enum.map(fn row ->
        Sol.make_line(row, find_row)
      end)
      |> Enum.filter(fn x -> x != nil end)
      |> Enum.sort()
      |> Enum.chunk_while(
        # To detect beginnings
        -1..-1,
        fn elem, acc ->
          [a1..a2, e1..e2] = [acc, elem]

          if Range.disjoint?(elem, acc) && e1 - a2 > 1 do
            {:cont, acc, elem}
          else
            {:cont, min(a1, e1)..max(a2, e2)}
          end
        end,
        fn acc ->
          {:cont, acc, acc}
        end
      )

    # Detect endings as well
    ranges =
      (ranges ++ [(unquote(upper_bound) + 1)..(unquote(upper_bound) + 1)])
      |> Enum.chunk_every(2, 1, :discard)

    gap_found = ranges |> Enum.any?(fn [_..e1, s2.._] -> s2 - e1 > 1 end)

    if gap_found do
      x =
        ranges
        |> Enum.map(fn [_..e1, s2.._] ->
          if s2 - e1 > 1 do
            e1 + 1
          else
            0
          end
        end)
        |> Enum.sum()

      [x, find_row]
    else
      []
    end
  end
end

[bx, by] =
  0..upper_bound
  |> Enum.map(fn i -> Sol.find_empty_coords(data, i) end)
  |> Enum.filter(fn c -> c != [] end)
  |> List.flatten()

tuning_freq = bx * 4_000_000 + by
IO.puts("Found @ [#{bx}, #{by}], tuning frequency of #{tuning_freq}")
