# dice.py
import random
import time
import os
import sys
from datetime import datetime

# ASCII art for dice faces (1-6)
DICE_FACES = {
    1: ["╔═══════╗", "║       ║", "║   ●   ║", "║       ║", "╚═══════╝"],
    2: ["╔═══════╗", "║ ●     ║", "║       ║", "║     ● ║", "╚═══════╝"],
    3: ["╔═══════╗", "║ ●     ║", "║   ●   ║", "║     ● ║", "╚═══════╝"],
    4: ["╔═══════╗", "║ ●   ● ║", "║       ║", "║ ●   ● ║", "╚═══════╝"],
    5: ["╔═══════╗", "║ ●   ● ║", "║   ●   ║", "║ ●   ● ║", "╚═══════╝"],
    6: ["╔═══════╗", "║ ● ● ● ║", "║ ● ● ● ║", "║ ● ● ● ║", "╚═══════╝"]
}

class DiceSimulator:
    def __init__(self):
        self.dice_type = 6  # Default D6
        self.num_dice = 1
        self.history = []
        self.stats = {"total_rolls": 0, "sum": 0, "min": float('inf'), "max": 0}
        self.animation_frames = 8

    def roll(self):
        """Roll dice with animation."""
        results = []
        for _ in range(self.num_dice):
            results.append(random.randint(1, self.dice_type))
        # Animate
        self._animate(results)
        return results

    def _animate(self, final_results):
        """Show animated rolling effect."""
        # Clear screen
        os.system('cls' if os.name == 'nt' else 'clear')
        print("🎲 Rolling dice...")
        time.sleep(0.3)
        for frame in range(self.animation_frames):
            # Show random dice faces during animation
            if frame < self.animation_frames - 1:
                temp_results = [random.randint(1, self.dice_type) for _ in range(self.num_dice)]
                self._display_dice(temp_results, "Rolling...")
            else:
                self._display_dice(final_results, "Result!")
            time.sleep(0.15)
            # Clear the dice display (move cursor up)
            lines_to_clear = 6 + self.num_dice * 6
            sys.stdout.write(f"\033[{lines_to_clear}A")
            sys.stdout.flush()
        # Final display
        self._display_dice(final_results, "Result!")

    def _display_dice(self, results, label):
        """Display dice faces."""
        print(f"\n🎲 {label}")
        print()
        # For multiple dice, show them side by side
        dice_lines = []
        for result in results:
            face = DICE_FACES.get(result, DICE_FACES[1])
            dice_lines.append(face)
        # Transpose to show side by side
        for line_idx in range(5):
            line_parts = []
            for die_idx in range(len(dice_lines)):
                line_parts.append(dice_lines[die_idx][line_idx])
            print("  ".join(line_parts))
        print(f"\nResults: {', '.join(map(str, results))}  Sum: {sum(results)}")
        # Update history and stats
        self._update_stats(results)

    def _update_stats(self, results):
        """Update history and statistics."""
        total = sum(results)
        self.history.append({"timestamp": datetime.now().isoformat(), "results": results, "sum": total})
        if len(self.history) > 10:
            self.history.pop(0)
        self.stats["total_rolls"] += 1
        self.stats["sum"] += total
        self.stats["min"] = min(self.stats["min"], min(results))
        self.stats["max"] = max(self.stats["max"], max(results))

    def show_history(self):
        if not self.history:
            print("No rolls yet.")
            return
        print("\n📜 Roll History (last 10):")
        for i, entry in enumerate(self.history, 1):
            print(f"  {i}. {entry['timestamp']}: {entry['results']} (sum: {entry['sum']})")

    def show_stats(self):
        if self.stats["total_rolls"] == 0:
            print("No rolls yet.")
            return
        avg = self.stats["sum"] / self.stats["total_rolls"]
        print(f"\n📊 Statistics:")
        print(f"  Total rolls: {self.stats['total_rolls']}")
        print(f"  Average sum: {avg:.2f}")
        print(f"  Min sum: {self.stats['min']}")
        print(f"  Max sum: {self.stats['max']}")

    def run(self):
        print("🎲 Dice Roll Simulator")
        while True:
            print("\n1. Roll dice")
            print("2. Show history")
            print("3. Show statistics")
            print(f"4. Change dice type (current: D{self.dice_type})")
            print(f"5. Change number of dice (current: {self.num_dice})")
            print("6. Exit")
            choice = input("Choose: ").strip()
            if choice == "1":
                self.roll()
            elif choice == "2":
                self.show_history()
            elif choice == "3":
                self.show_stats()
            elif choice == "4":
                new_type = input("Enter dice type (4, 6, 8, 10, 12, 20, 100): ").strip()
                if new_type.isdigit() and int(new_type) in [4, 6, 8, 10, 12, 20, 100]:
                    self.dice_type = int(new_type)
                    print(f"Dice type changed to D{self.dice_type}")
                else:
                    print("Invalid dice type.")
            elif choice == "5":
                new_num = input("Enter number of dice (1-6): ").strip()
                if new_num.isdigit() and 1 <= int(new_num) <= 6:
                    self.num_dice = int(new_num)
                    print(f"Number of dice changed to {self.num_dice}")
                else:
                    print("Invalid number.")
            elif choice == "6":
                print("Goodbye!")
                break
            else:
                print("Invalid choice.")

if __name__ == "__main__":
    sim = DiceSimulator()
    sim.run()
