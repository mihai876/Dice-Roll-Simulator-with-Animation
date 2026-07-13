// dice.swift
import Foundation

let DICE_FACES: [Int: [String]] = [
    1: ["╔═══════╗", "║       ║", "║   ●   ║", "║       ║", "╚═══════╝"],
    2: ["╔═══════╗", "║ ●     ║", "║       ║", "║     ● ║", "╚═══════╝"],
    3: ["╔═══════╗", "║ ●     ║", "║   ●   ║", "║     ● ║", "╚═══════╝"],
    4: ["╔═══════╗", "║ ●   ● ║", "║       ║", "║ ●   ● ║", "╚═══════╝"],
    5: ["╔═══════╗", "║ ●   ● ║", "║   ●   ║", "║ ●   ● ║", "╚═══════╝"],
    6: ["╔═══════╗", "║ ● ● ● ║", "║ ● ● ● ║", "║ ● ● ● ║", "╚═══════╝"]
]

struct HistoryEntry {
    let timestamp: String
    let results: [Int]
    let sum: Int
}

class DiceSimulator {
    var diceType = 6
    var numDice = 1
    var history: [HistoryEntry] = []
    var totalRolls = 0
    var sumTotal = 0
    var minSum = Int.max
    var maxSum = Int.min
    let animationFrames = 8

    func roll() -> [Int] {
        var results: [Int] = []
        for _ in 0..<numDice {
            results.append(Int.random(in: 1...diceType))
        }
        animate(finalResults: results)
        return results
    }

    func animate(finalResults: [Int]) {
        print("\u{001B}[2J\u{001B}[H", terminator: "")
        print("🎲 Rolling dice...")
        Thread.sleep(forTimeInterval: 0.3)

        for frame in 0..<animationFrames {
            let tempResults = frame < animationFrames - 1
                ? (0..<numDice).map { _ in Int.random(in: 1...diceType) }
                : finalResults
            displayDice(results: tempResults, label: "Rolling...")
            Thread.sleep(forTimeInterval: 0.15)
            let lines = 6 + numDice * 5
            print("\u{001B}[\(lines)A", terminator: "")
        }
        displayDice(results: finalResults, label: "Result!")
    }

    func displayDice(results: [Int], label: String) {
        print("\n🎲 \(label)\n")
        let diceLines = results.map { DICE_FACES[$0] ?? DICE_FACES[1]! }
        for line in 0..<5 {
            let parts = diceLines.map { $0[line] }
            print(parts.joined(separator: "  "))
        }
        let sum = results.reduce(0, +)
        print("\nResults: \(results.map(String.init).joined(separator: ", "))  Sum: \(sum)")
        updateStats(results: results, sum: sum)
    }

    func updateStats(results: [Int], sum: Int) {
        let entry = HistoryEntry(
            timestamp: Date().ISO8601Format(),
            results: results,
            sum: sum
        )
        history.append(entry)
        if history.count > 10 { history.removeFirst() }
        totalRolls += 1
        sumTotal += sum
        minSum = min(minSum, sum)
        maxSum = max(maxSum, sum)
    }

    func showHistory() {
        if history.isEmpty {
            print("No rolls yet.")
            return
        }
        print("\n📜 Roll History (last 10):")
        for (i, entry) in history.enumerated() {
            print("  \(i+1). \(entry.timestamp): \(entry.results) (sum: \(entry.sum))")
        }
    }

    func showStats() {
        if totalRolls == 0 {
            print("No rolls yet.")
            return
        }
        let avg = Double(sumTotal) / Double(totalRolls)
        print("\n📊 Statistics:")
        print("  Total rolls: \(totalRolls)")
        print("  Average sum: \(String(format: "%.2f", avg))")
        print("  Min sum: \(minSum)")
        print("  Max sum: \(maxSum)")
    }

    func run() {
        print("🎲 Dice Roll Simulator")
        while true {
            print("\n1. Roll dice")
            print("2. Show history")
            print("3. Show statistics")
            print("4. Change dice type (current: D\(diceType))")
            print("5. Change number of dice (current: \(numDice))")
            print("6. Exit")
            print("Choose: ", terminator: "")
            guard let choice = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else { continue }
            switch choice {
            case "1":
                _ = roll()
            case "2":
                showHistory()
            case "3":
                showStats()
            case "4":
                print("Enter dice type (4, 6, 8, 10, 12, 20, 100): ", terminator: "")
                if let typ = readLine(), let val = Int(typ), [4,6,8,10,12,20,100].contains(val) {
                    diceType = val
                    print("Dice type changed to D\(diceType)")
                } else {
                    print("Invalid dice type.")
                }
            case "5":
                print("Enter number of dice (1-6): ", terminator: "")
                if let num = readLine(), let val = Int(num), val >= 1, val <= 6 {
                    numDice = val
                    print("Number of dice changed to \(numDice)")
                } else {
                    print("Invalid number.")
                }
            case "6":
                print("Goodbye!")
                return
            default:
                print("Invalid choice.")
            }
        }
    }
}

let sim = DiceSimulator()
sim.run()
