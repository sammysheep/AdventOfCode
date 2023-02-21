// Sam Shepard - 2023
// First time F#!

let filename =
    if fsi.CommandLineArgs.Length > 1 then
        fsi.CommandLineArgs[1]
    else
        "test.txt"

let data =
    System.IO.File.ReadAllText(filename).Split("\n")
    |> Array.filter (fun line -> line.Length > 0)
    |> Array.map (fun r -> r.Split(",") |> Array.map int)

let s = data |> set

let diff =
    [| [| 1; 0; 0 |]
       [| 0; 1; 0 |]
       [| 0; 0; 1 |]
       [| -1; 0; 0 |]
       [| 0; -1; 0 |]
       [| 0; 0; -1 |] |]

let surface_area =
    data
    |> Array.allPairs diff
    |> Array.map (fun (x, y) -> Array.map2 (+) x y)
    |> Array.filter (s.Contains >> not)
    |> Array.length

printfn $"The surface area was {surface_area}"
