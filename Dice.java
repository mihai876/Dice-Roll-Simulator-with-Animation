// Dice.java
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

public class Dice {
    private static final Map<Integer, String[]> DICE_FACES = new HashMap<>();
    static {
        DICE_FACES.put(1, new String[]{"╔═══════╗", "║       ║", "║   ●   ║", "║       ║", "╚═══════╝"});
        DICE_FACES.put(2, new String[]{"╔═══════╗", "║ ●     ║", "║       ║", "║     ● ║", "╚═══════╝"});
        DICE_FACES.put(3, new String[]{"╔═══════╗", "║ ●     ║", "║   ●   ║", "║     ● ║", "╚═══════╝"});
        DICE_FACES.put(4, new String[]{"╔═══════╗", "║ ●   ● ║", "║       ║", "║ ●   ● ║", "╚═══════╝"});
        DICE_FACES.put(5, new String[]{"╔═══════╗", "║ ●   ● ║", "║   ●   ║", "║ ●   ● ║", "╚═══════╝"});
        DICE_FACES.put(6, new String[]{"╔═══════╗", "║ ● ● ● ║", "║ ● ● ● ║", "║ ● ● ● ║", "╚═══════╝"});
    }

    private int diceType = 6;
    private int numDice = 1;
    private List<HistoryEntry> history = new ArrayList<>();
    private int totalRolls = 0;
    private int sumTotal = 0;
    private int minSum = Integer.MAX_VALUE;
    private int maxSum = Integer.MIN_VALUE;
    private Random rand = new Random();
    private int animationFrames = 8;

    static class HistoryEntry {
        String timestamp;
        List<Integer> results;
        int sum;
        HistoryEntry(String ts, List<Integer> res, int s) { timestamp = ts; results = res; sum = s; }
    }

    public void roll() {
        List<Integer> results = new ArrayList<>();
        for (int i = 0; i < numDice; i++)
            results.add(rand.nextInt(diceType) + 1);
        animate(results);
    }

    private void animate(List<Integer> finalResults) {
        System.out.print("\033[H\033[2J");
        System.out.flush();
        System.out.println("🎲 Rolling dice...");
        try { Thread.sleep(300); } catch (InterruptedException e) {}

        for (int frame = 0; frame < animationFrames; frame++) {
            List<Integer> tempResults = frame < animationFrames - 1
                ? rand.ints(numDice, 1, diceType + 1).boxed().collect(Collectors.toList())
                : finalResults;
            displayDice(tempResults, "Rolling...");
            try { Thread.sleep(150); } catch (InterruptedException e) {}
            int lines = 6 + numDice * 5;
            System.out.printf("\033[%dA", lines);
        }
        displayDice(finalResults, "Result!");
    }

    private void displayDice(List<Integer> results, String label) {
        System.out.printf("\n🎲 %s\n\n", label);
        List<String[]> diceLines = results.stream()
            .map(r -> DICE_FACES.getOrDefault(r, DICE_FACES.get(1)))
            .collect(Collectors.toList());
        for (int line = 0; line < 5; line++) {
            List<String> parts = new ArrayList<>();
            for (String[] face : diceLines) parts.add(face[line]);
            System.out.println(String.join("  ", parts));
        }
        int sum = results.stream().mapToInt(Integer::intValue).sum();
        System.out.printf("\nResults: %s  Sum: %d\n", results.toString().replaceAll("[\\[\\]]", ""), sum);
        updateStats(results, sum);
    }

    private void updateStats(List<Integer> results, int sum) {
        history.add(new HistoryEntry(
            LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")),
            new ArrayList<>(results), sum));
        if (history.size() > 10) history.remove(0);
        totalRolls++;
        sumTotal += sum;
        if (sum < minSum) minSum = sum;
        if (sum > maxSum) maxSum = sum;
    }

    public void showHistory() {
        if (history.isEmpty()) { System.out.println("No rolls yet."); return; }
        System.out.println("\n📜 Roll History (last 10):");
        for (int i = 0; i < history.size(); i++)
            System.out.printf("  %d. %s: %s (sum: %d)%n", i+1, history.get(i).timestamp,
                history.get(i).results.toString().replaceAll("[\\[\\]]", ""), history.get(i).sum);
    }

    public void showStats() {
        if (totalRolls == 0) { System.out.println("No rolls yet."); return; }
        double avg = (double) sumTotal / totalRolls;
        System.out.println("\n📊 Statistics:");
        System.out.printf("  Total rolls: %d%n", totalRolls);
        System.out.printf("  Average sum: %.2f%n", avg);
        System.out.printf("  Min sum: %d%n", minSum);
        System.out.printf("  Max sum: %d%n", maxSum);
    }

    public void run() {
        Scanner scanner = new Scanner(System.in);
        System.out.println("🎲 Dice Roll Simulator");
        while (true) {
            System.out.println("\n1. Roll dice");
            System.out.println("2. Show history");
            System.out.println("3. Show statistics");
            System.out.printf("4. Change dice type (current: D%d)%n", diceType);
            System.out.printf("5. Change number of dice (current: %d)%n", numDice);
            System.out.println("6. Exit");
            System.out.print("Choose: ");
            String choice = scanner.nextLine().trim();
            switch (choice) {
                case "1": roll(); break;
                case "2": showHistory(); break;
                case "3": showStats(); break;
                case "4":
                    System.out.print("Enter dice type (4, 6, 8, 10, 12, 20, 100): ");
                    try {
                        int typ = Integer.parseInt(scanner.nextLine().trim());
                        if (typ == 4 || typ == 6 || typ == 8 || typ == 10 || typ == 12 || typ == 20 || typ == 100) {
                            diceType = typ;
                            System.out.printf("Dice type changed to D%d%n", diceType);
                        } else System.out.println("Invalid dice type.");
                    } catch (NumberFormatException e) { System.out.println("Invalid dice type."); }
                    break;
                case "5":
                    System.out.print("Enter number of dice (1-6): ");
                    try {
                        int num = Integer.parseInt(scanner.nextLine().trim());
                        if (num >= 1 && num <= 6) {
                            numDice = num;
                            System.out.printf("Number of dice changed to %d%n", numDice);
                        } else System.out.println("Invalid number.");
                    } catch (NumberFormatException e) { System.out.println("Invalid number."); }
                    break;
                case "6": System.out.println("Goodbye!"); scanner.close(); return;
                default: System.out.println("Invalid choice.");
            }
        }
    }

    public static void main(String[] args) {
        new Dice().run();
    }
}
