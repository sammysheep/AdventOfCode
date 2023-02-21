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

let s: Set<int[]> = data |> set

let max = (data |> Array.reduce Array.append |> Array.max)
let min = (data |> Array.reduce Array.append |> Array.min)

printfn $"Min {min} to Max {max}"

let array_span: int[] = [| 0 .. (max + 1) |]
let lb: int = 0
let ub: int = max + 1

let cube: bool[][][] =
    Array.collect
        (fun x ->
            [| Array.collect
                   (fun y -> [| Array.collect (fun z -> [| s.Contains([| x; y; z |]) |]) array_span |])
                   array_span |])
        array_span

let diff =
    [| [| 1; 0; 0 |]
       [| 0; 1; 0 |]
       [| 0; 0; 1 |]
       [| -1; 0; 0 |]
       [| 0; -1; 0 |]
       [| 0; 0; -1 |] |]

let rec check_directions (p: int[]) =
    match p with
    | [| x; y; z |] ->
        cube.[x].[y].[z] <- true

        [| p |]
        |> Array.allPairs diff
        |> Array.map (fun (x, y) -> Array.map2 (+) x y)
        |> Array.filter (fun coords ->
            match coords with
            | [| x; y; z |] -> ub >= x && x >= lb && ub >= y && y >= lb && ub >= z && z >= lb
            | _ -> false)
        |> Array.filter (fun coords ->
            match coords with
            | [| x; y; z |] -> not cube.[x].[y].[z]
            | _ -> false)
        |> Array.map (fun coords -> check_directions coords)
        |> Array.length
    | _ -> 0

check_directions [| max + 1; max + 1; max + 1 |]

let surface_area =
    data
    |> Array.allPairs diff
    |> Array.map (fun (x, y) -> Array.map2 (+) x y)
    |> Array.filter (s.Contains >> not)
    |> Array.filter (fun coords ->
        match coords with
        // Padding prevents index errors for the ub, and the -1 check is necessary for the lb
        | [| -1; _; _ |] -> true
        | [| _; -1; _ |] -> true
        | [| _; _; -1 |] -> true
        | [| x; y; z |] -> cube.[x].[y].[z]
        | _ -> false)
    |> Array.length

printfn $"The surface area was {surface_area}"
