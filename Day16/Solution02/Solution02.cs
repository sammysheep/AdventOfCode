// Sam Shepard - 2023
// Giving C# a second look.

using System.Text.RegularExpressions;

string filename = "test.txt";
if (args.Length > 0)
{
    filename = args[0];
}

if (!File.Exists(filename))
{
    Console.WriteLine($"No file found named '{filename}'");
    System.Environment.Exit(1);
}

Dictionary<string, int> rates = new Dictionary<string, int>();
Dictionary<string, string[]> paths = new Dictionary<string, string[]>();

var data = File.ReadAllText(filename).Split("\n").Where(s => s.Length > 0);
var pattern = new Regex(@"Valve (\w\w).+?rate=(\d+);.+?valves? ([A-Z ,]+)");
foreach (string line in data)
{
    var match = pattern.Match(line);
    var (ID, rate, tunnels) = (match.Groups[1].Value, Int32.Parse(match.Groups[2].Value), match.Groups[3].Value.Split(", "));

    if (rate > 0)
    {
        rates[ID] = rate;
    }

    paths[ID] = tunnels;
}

// Breadth First Search
int find_steps(string from, string target, Dictionary<string, string[]> paths)
{
    var Q = new Queue<Node>();
    var explored = new HashSet<string>();

    Q.Enqueue(new Node(from, 0));
    explored.Add(from);
    while (Q.Count() > 0)
    {
        var current = Q.Dequeue();
        if (current.id == target)
        {
            return current.steps;
        }
        string[] tunnels = paths[current.id];
        foreach (string tunnel in tunnels)
        {
            if (!explored.Contains(tunnel))
            {
                explored.Add(tunnel);
                Q.Enqueue(new Node(tunnel, current.steps + 1));
            }
        }
    }
    return -1;
}

HashSet<string> search_list = rates.Keys.ToHashSet();
search_list.Add("AA");

string[] ids = search_list.ToArray();
Array.Sort(ids);

int n = ids.Length;
rates["AA"] = 0;
Distance[,] distances = new Distance[n, n];

// Fill Distance Matrix
for (int i = 0; i < n - 1; i++)
{
    for (int j = i + 1; j < n; j++)
    {
        if (i != j)
        {
            // from i to j
            // distance is symmetric but flow rate is not
            int steps = find_steps(ids[i], ids[j], paths);
            distances[i, j] = new Distance(d: steps, flow: rates[ids[j]]);
            distances[j, i] = new Distance(d: steps, flow: rates[ids[i]]);
        }
        else
        {
            distances[i, i] = new Distance(d: 0, flow: 0);
        }
    }
}

// 2^N * N
Cost[,] partials = new Cost[1 << n, n];


// Held-Karp DP solution to Traveling Salesman Problem
// Very possibly I missed something and the puzzle isn't supposed to be NP-hard!

// Costs to the first node.
for (int k = 1; k < n; k++)
{
    // Change starting time
    partials[(1 << k), k] = AccumulateCost(new Cost(0, 26), distances[0, k]);
}

// Costs for all other subsets.
for (int subset_size = 2; subset_size < n; subset_size++)
{
    foreach (int subset in GetBitPermutation(subset_size, n))
    {
        var positions = MaskToList(subset, n);
        foreach (int p in positions)
        {
            int previous = subset & ~(1 << p);

            partials[subset, p] = positions
                .Where(m => m != 0 && m != p)
                .Select(m => AccumulateCost(partials[previous, m], distances[m, p]))
                .MinBy(c => c.pressure);
        }
    }
}

int last_subset = ((1 << n) - 1) - 1;
int total_pressure = -Enumerable.Range(1, n - 1).Select(k => partials[last_subset, k].pressure).Min();

// Turn our pressures into a 1D array
int[] pressures = new int[last_subset + 1];
for (int subset = 2; subset <= last_subset; subset++)
{

    int min = Int32.MaxValue;
    for (int k = 1; k < n; k++)
    {
        if (partials[subset, k].pressure < min)
        {
            min = partials[subset, k].pressure;
        }
    }
    pressures[subset] = min;
}

// 💪 Brute force the solution over the lower triangle
// Hey, I'm tired of this puzzle here!
int combined_min_pressure = Int32.MaxValue;
for (int s1 = 2; s1 <= last_subset - 1; s1++)
{
    for (int s2 = s1 + 1; s2 <= last_subset; s2++)
    {
        // bit masks must be complementary
        if ((s2 ^ s1) == last_subset)
        {
            int sum = pressures[s1] + pressures[s2];
            if (sum < combined_min_pressure)
            {
                combined_min_pressure = sum;
            }
        }
    }

}

Console.WriteLine($"Released {-combined_min_pressure} combined pressure with help from the elephant.");


List<int> MaskToList(int mask, int n = 32)
{
    List<int> list = new List<int>();
    for (int position = 0; position < n; position++)
    {
        if ((mask & (1 << position)) > 0)
        {

            list.Add(position);
        }
    }
    return list;
}

// Modified to avoid the 0th bit
// Bit permutations: https://graphics.stanford.edu/%7Eseander/bithacks.html#NextBitPermutation
IEnumerable<int> GetBitPermutation(int k, int n)
{
    int current = (1 << k) - 1;

    if ((1 & current) == 0)
    {
        yield return current;
    }

    int end = current << (n - k);
    while (current != end)
    {
        int temp = (current | (current - 1)) + 1;
        current = temp | ((((temp & -temp) / (current & -current)) >> 1) - 1);
        if ((1 & current) == 0)
        {
            yield return current;
        }
    }
}

Cost AccumulateCost(Cost cost, Distance dist)
{
    int t = cost.time - 1 - dist.d;
    if (t >= 0)
    {
        return new Cost(cost.pressure - (t * dist.flow), t);
    }
    else
    {
        return new Cost(cost.pressure, 0);
    }
}


public record struct Distance(int d, int flow);
public record struct Cost(int pressure, int time);

struct Node
{
    public string id;
    public int steps = 0;

    public Node(string i, int s)
    {
        this.id = i;
        this.steps = s;
    }
}