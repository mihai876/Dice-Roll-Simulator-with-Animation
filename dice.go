// dice.go
package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"time"
)

// ASCII art for dice faces
var diceFaces = map[int][]string{
	1: {"╔═══════╗", "║       ║", "║   ●   ║", "║       ║", "╚═══════╝"},
	2: {"╔═══════╗", "║ ●     ║", "║       ║", "║     ● ║", "╚═══════╝"},
	3: {"╔═══════╗", "║ ●     ║", "║   ●   ║", "║     ● ║", "╚═══════╝"},
	4: {"╔═══════╗", "║ ●   ● ║", "║       ║", "║ ●   ● ║", "╚═══════╝"},
	5: {"╔═══════╗", "║ ●   ● ║", "║   ●   ║", "║ ●   ● ║", "╚═══════╝"},
	6: {"╔═══════╗", "║ ● ● ● ║", "║ ● ● ● ║", "║ ● ● ● ║", "╚═══════╝"},
}

type HistoryEntry struct {
	Timestamp string
	Results   []int
	Sum       int
}

type DiceSimulator struct {
	diceType       int
	numDice        int
	history        []HistoryEntry
	totalRolls     int
	sumTotal       int
	minSum         int
	maxSum         int
	animationFrames int
}

func NewDiceSimulator() *DiceSimulator {
	return &DiceSimulator{
		diceType:       6,
		numDice:        1,
		history:        []HistoryEntry{},
		animationFrames: 8,
		minSum:         int(^uint(0) >> 1), // max int
	}
}

func (d *DiceSimulator) roll() []int {
	results := make([]int, d.numDice)
	for i := range results {
		results[i] = rand.Intn(d.diceType) + 1
	}
	d.animate(results)
	return results
}

func (d *DiceSimulator) animate(finalResults []int) {
	fmt.Print("\033[H\033[2J") // clear screen
	fmt.Println("🎲 Rolling dice...")
	time.Sleep(300 * time.Millisecond)

	for frame := 0; frame < d.animationFrames; frame++ {
		var tempResults []int
		if frame < d.animationFrames-1 {
			tempResults = make([]int, d.numDice)
			for i := range tempResults {
				tempResults[i] = rand.Intn(d.diceType) + 1
			}
		} else {
			tempResults = finalResults
		}
		d.displayDice(tempResults, "Rolling...")
		time.Sleep(150 * time.Millisecond)
		// Move cursor up
		lines := 6 + d.numDice*5
		fmt.Printf("\033[%dA", lines)
	}
	d.displayDice(finalResults, "Result!")
}

func (d *DiceSimulator) displayDice(results []int, label string) {
	fmt.Printf("\n🎲 %s\n\n", label)
	// Build dice faces for each result
	diceLines := make([][]string, len(results))
	for i, res := range results {
		if face, ok := diceFaces[res]; ok {
			diceLines[i] = face
		} else {
			diceLines[i] = diceFaces[1]
		}
	}
	// Print side by side
	for line := 0; line < 5; line++ {
		for die := 0; die < len(diceLines); die++ {
			fmt.Print(diceLines[die][line])
			if die < len(diceLines)-1 {
				fmt.Print("  ")
			}
		}
		fmt.Println()
	}
	sum := 0
	fmt.Print("\nResults: ")
	for i, res := range results {
		fmt.Print(res)
		if i < len(results)-1 {
			fmt.Print(", ")
		}
		sum += res
	}
	fmt.Printf("  Sum: %d\n", sum)
	d.updateStats(results, sum)
}

func (d *DiceSimulator) updateStats(results []int, sum int) {
	entry := HistoryEntry{
		Timestamp: time.Now().Format("2006-01-02 15:04:05"),
		Results:   results,
		Sum:       sum,
	}
	d.history = append(d.history, entry)
	if len(d.history) > 10 {
		d.history = d.history[1:]
	}
	d.totalRolls++
	d.sumTotal += sum
	if sum < d.minSum {
		d.minSum = sum
	}
	if sum > d.maxSum {
		d.maxSum = sum
	}
}

func (d *DiceSimulator) showHistory() {
	if len(d.history) == 0 {
		fmt.Println("No rolls yet.")
		return
	}
	fmt.Println("\n📜 Roll History (last 10):")
	for i, entry := range d.history {
		fmt.Printf("  %d. %s: %v (sum: %d)\n", i+1, entry.Timestamp, entry.Results, entry.Sum)
	}
}

func (d *DiceSimulator) showStats() {
	if d.totalRolls == 0 {
		fmt.Println("No rolls yet.")
		return
	}
	avg := float64(d.sumTotal) / float64(d.totalRolls)
	fmt.Printf("\n📊 Statistics:\n")
	fmt.Printf("  Total rolls: %d\n", d.totalRolls)
	fmt.Printf("  Average sum: %.2f\n", avg)
	fmt.Printf("  Min sum: %d\n", d.minSum)
	fmt.Printf("  Max sum: %d\n", d.maxSum)
}

func main() {
	rand.Seed(time.Now().UnixNano())
	sim := NewDiceSimulator()
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Println("🎲 Dice Roll Simulator")
	for {
		fmt.Println("\n1. Roll dice")
		fmt.Println("2. Show history")
		fmt.Println("3. Show statistics")
		fmt.Printf("4. Change dice type (current: D%d)\n", sim.diceType)
		fmt.Printf("5. Change number of dice (current: %d)\n", sim.numDice)
		fmt.Println("6. Exit")
		fmt.Print("Choose: ")
		scanner.Scan()
		choice := strings.TrimSpace(scanner.Text())
		switch choice {
		case "1":
			sim.roll()
		case "2":
			sim.showHistory()
		case "3":
			sim.showStats()
		case "4":
			fmt.Print("Enter dice type (4, 6, 8, 10, 12, 20, 100): ")
			scanner.Scan()
			typ := strings.TrimSpace(scanner.Text())
			val, err := strconv.Atoi(typ)
			if err == nil && (val == 4 || val == 6 || val == 8 || val == 10 || val == 12 || val == 20 || val == 100) {
				sim.diceType = val
				fmt.Printf("Dice type changed to D%d\n", sim.diceType)
			} else {
				fmt.Println("Invalid dice type.")
			}
		case "5":
			fmt.Print("Enter number of dice (1-6): ")
			scanner.Scan()
			num := strings.TrimSpace(scanner.Text())
			val, err := strconv.Atoi(num)
			if err == nil && val >= 1 && val <= 6 {
				sim.numDice = val
				fmt.Printf("Number of dice changed to %d\n", sim.numDice)
			} else {
				fmt.Println("Invalid number.")
			}
		case "6":
			fmt.Println("Goodbye!")
			return
		default:
			fmt.Println("Invalid choice.")
		}
	}
}
