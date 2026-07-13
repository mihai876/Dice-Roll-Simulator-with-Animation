// Dice.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;

class DiceSimulator
{
    private static readonly Dictionary<int, string[]> DICE_FACES = new Dictionary<int, string[]>
    {
        {1, new[] {"╔═══════╗", "║       ║", "║   ●   ║", "║       ║", "╚═══════╝"}},
        {2, new[] {"╔═══════╗", "║ ●     ║", "║       ║", "║     ● ║", "╚═══════╝"}},
        {3, new[] {"╔═══════╗", "║ ●     ║", "║   ●   ║", "║     ● ║", "╚═══════╝"}},
        {4, new[] {"╔═══════╗", "║ ●   ● ║", "║       ║", "║ ●   ● ║", "╚═══════╝"}},
        {5, new[] {"╔═══════╗", "║ ●   ● ║", "║   ●   ║", "║ ●   ● ║", "╚═══════╝"}},
        {6, new[] {"╔═══════╗", "║ ● ● ● ║", "║ ● ● ● ║", "║ ● ● ● ║", "╚═══════╝"}}
    };

    private int diceType = 6;
    private int numDice = 1;
    private List<(string timestamp, List<int> results, int sum)> history = new List<(string, List<int>, int)>();
    private int totalRolls = 0;
    private int sumTotal = 0;
    private int minSum = int.MaxValue;
    private int maxSum = int.MinValue;
    private Random rand = new Random();
    private int animationFrames = 8;

    public void Roll()
    {
        var results = new List<int>();
        for (int i = 0; i < numDice; i++)
            results.Add(rand.Next(1, diceType + 1));
        Animate(results);
    }

    private void Animate(List<int> finalResults)
    {
        Console.Clear();
        Console.WriteLine("🎲 Rolling dice...");
        Thread.Sleep(300);

        for (int frame = 0; frame < animationFrames; frame++)
        {
            var tempResults = frame < animationFrames - 1
                ? Enumerable.Range(0, numDice).Select(_ => rand.Next(1, diceType + 1)).ToList()
                : finalResults;
            DisplayDice(tempResults, "Rolling...");
            Thread.Sleep(150);
            int lines = 6 + numDice * 5;
            Console.SetCursorPosition(0, Console.CursorTop - lines);
        }
        DisplayDice(finalResults, "Result!");
    }

    private void DisplayDice(List<int> results, string label)
    {
        Console.WriteLine($"\n🎲 {label}\n");
        var diceLines = results.Select(r => DICE_FACES.ContainsKey(r) ? DICE_FACES[r] : DICE_FACES[1]).ToList();
        for (int line = 0; line < 5; line++)
        {
            var parts = diceLines.Select(face => face[line]).ToList();
            Console.WriteLine(string.Join("  ", parts));
        }
        int sum = results.Sum();
        Console.WriteLine($"\nResults: {string.Join(", ", results)}  Sum: {sum}");
        UpdateStats(results, sum);
    }

    private void UpdateStats(List<int> results, int sum)
    {
        history.Add((DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), new List<int>(results), sum));
        if (history.Count > 10) history.RemoveAt(0);
        totalRolls++;
        sumTotal += sum;
        if (sum < minSum) minSum = sum;
        if (sum > maxSum) maxSum = sum;
    }

    public void ShowHistory()
    {
        if (history.Count == 0) { Console.WriteLine("No rolls yet."); return; }
        Console.WriteLine("\n📜 Roll History (last 10):");
        for (int i = 0; i < history.Count; i++)
            Console.WriteLine($"  {i+1}. {history[i].timestamp}: [{string.Join(", ", history[i].results)}] (sum: {history[i].sum})");
    }

    public void ShowStats()
    {
        if (totalRolls == 0) { Console.WriteLine("No rolls yet."); return; }
        double avg = (double)sumTotal / totalRolls;
        Console.WriteLine("\n📊 Statistics:");
        Console.WriteLine($"  Total rolls: {totalRolls}");
        Console.WriteLine($"  Average sum: {avg:F2}");
        Console.WriteLine($"  Min sum: {minSum}");
        Console.WriteLine($"  Max sum: {maxSum}");
    }

    public void Run()
    {
        Console.WriteLine("🎲 Dice Roll Simulator");
        while (true)
        {
            Console.WriteLine("\n1. Roll dice");
            Console.WriteLine("2. Show history");
            Console.WriteLine("3. Show statistics");
            Console.WriteLine($"4. Change dice type (current: D{diceType})");
            Console.WriteLine($"5. Change number of dice (current: {numDice})");
            Console.WriteLine("6. Exit");
            Console.Write("Choose: ");
            string choice = Console.ReadLine()?.Trim();
            switch (choice)
            {
                case "1": Roll(); break;
                case "2": ShowHistory(); break;
                case "3": ShowStats(); break;
                case "4":
                    Console.Write("Enter dice type (4, 6, 8, 10, 12, 20, 100): ");
                    if (int.TryParse(Console.ReadLine(), out int typ) && new[] {4,6,8,10,12,20,100}.Contains(typ))
                    { diceType = typ; Console.WriteLine($"Dice type changed to D{diceType}"); }
                    else Console.WriteLine("Invalid dice type.");
                    break;
                case "5":
                    Console.Write("Enter number of dice (1-6): ");
                    if (int.TryParse(Console.ReadLine(), out int num) && num >= 1 && num <= 6)
                    { numDice = num; Console.WriteLine($"Number of dice changed to {numDice}"); }
                    else Console.WriteLine("Invalid number.");
                    break;
                case "6": Console.WriteLine("Goodbye!"); return;
                default: Console.WriteLine("Invalid choice."); break;
            }
        }
    }

    static void Main() => new DiceSimulator().Run();
}
