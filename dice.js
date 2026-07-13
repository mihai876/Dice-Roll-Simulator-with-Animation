// dice.js
const readline = require('readline');
const { setTimeout } = require('timers/promises');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

// ASCII art for dice faces
const DICE_FACES = {
    1: ["╔═══════╗", "║       ║", "║   ●   ║", "║       ║", "╚═══════╝"],
    2: ["╔═══════╗", "║ ●     ║", "║       ║", "║     ● ║", "╚═══════╝"],
    3: ["╔═══════╗", "║ ●     ║", "║   ●   ║", "║     ● ║", "╚═══════╝"],
    4: ["╔═══════╗", "║ ●   ● ║", "║       ║", "║ ●   ● ║", "╚═══════╝"],
    5: ["╔═══════╗", "║ ●   ● ║", "║   ●   ║", "║ ●   ● ║", "╚═══════╝"],
    6: ["╔═══════╗", "║ ● ● ● ║", "║ ● ● ● ║", "║ ● ● ● ║", "╚═══════╝"]
};

class DiceSimulator {
    constructor() {
        this.diceType = 6;
        this.numDice = 1;
        this.history = [];
        this.totalRolls = 0;
        this.sumTotal = 0;
        this.minSum = Infinity;
        this.maxSum = -Infinity;
        this.animationFrames = 8;
    }

    roll() {
        const results = [];
        for (let i = 0; i < this.numDice; i++) {
            results.push(Math.floor(Math.random() * this.diceType) + 1);
        }
        this.animate(results);
        return results;
    }

    async animate(finalResults) {
        console.clear();
        console.log('🎲 Rolling dice...');
        await setTimeout(300);

        for (let frame = 0; frame < this.animationFrames; frame++) {
            const tempResults = frame < this.animationFrames - 1
                ? Array.from({length: this.numDice}, () => Math.floor(Math.random() * this.diceType) + 1)
                : finalResults;
            this.displayDice(tempResults, 'Rolling...');
            await setTimeout(150);
            const lines = 6 + this.numDice * 5;
            console.log(`\x1b[${lines}A`);
        }
        this.displayDice(finalResults, 'Result!');
    }

    displayDice(results, label) {
        console.log(`\n🎲 ${label}\n`);
        const diceLines = results.map(r => DICE_FACES[r] || DICE_FACES[1]);
        for (let line = 0; line < 5; line++) {
            const parts = diceLines.map(face => face[line]);
            console.log(parts.join('  '));
        }
        const sum = results.reduce((a, b) => a + b, 0);
        console.log(`\nResults: ${results.join(', ')}  Sum: ${sum}`);
        this.updateStats(results, sum);
    }

    updateStats(results, sum) {
        this.history.push({
            timestamp: new Date().toISOString(),
            results: [...results],
            sum: sum
        });
        if (this.history.length > 10) this.history.shift();
        this.totalRolls++;
        this.sumTotal += sum;
        if (sum < this.minSum) this.minSum = sum;
        if (sum > this.maxSum) this.maxSum = sum;
    }

    showHistory() {
        if (this.history.length === 0) {
            console.log('No rolls yet.');
            return;
        }
        console.log('\n📜 Roll History (last 10):');
        this.history.forEach((entry, i) => {
            console.log(`  ${i+1}. ${entry.timestamp}: ${entry.results} (sum: ${entry.sum})`);
        });
    }

    showStats() {
        if (this.totalRolls === 0) {
            console.log('No rolls yet.');
            return;
        }
        const avg = this.sumTotal / this.totalRolls;
        console.log('\n📊 Statistics:');
        console.log(`  Total rolls: ${this.totalRolls}`);
        console.log(`  Average sum: ${avg.toFixed(2)}`);
        console.log(`  Min sum: ${this.minSum}`);
        console.log(`  Max sum: ${this.maxSum}`);
    }
}

function ask(question) {
    return new Promise(resolve => rl.question(question, resolve));
}

async function main() {
    const sim = new DiceSimulator();
    console.log('🎲 Dice Roll Simulator');
    while (true) {
        console.log('\n1. Roll dice');
        console.log('2. Show history');
        console.log('3. Show statistics');
        console.log(`4. Change dice type (current: D${sim.diceType})`);
        console.log(`5. Change number of dice (current: ${sim.numDice})`);
        console.log('6. Exit');
        const choice = await ask('Choose: ');
        switch (choice.trim()) {
            case '1':
                sim.roll();
                break;
            case '2':
                sim.showHistory();
                break;
            case '3':
                sim.showStats();
                break;
            case '4': {
                const typ = await ask('Enter dice type (4, 6, 8, 10, 12, 20, 100): ');
                const val = parseInt(typ);
                if (!isNaN(val) && [4,6,8,10,12,20,100].includes(val)) {
                    sim.diceType = val;
                    console.log(`Dice type changed to D${sim.diceType}`);
                } else {
                    console.log('Invalid dice type.');
                }
                break;
            }
            case '5': {
                const num = await ask('Enter number of dice (1-6): ');
                const val = parseInt(num);
                if (!isNaN(val) && val >= 1 && val <= 6) {
                    sim.numDice = val;
                    console.log(`Number of dice changed to ${sim.numDice}`);
                } else {
                    console.log('Invalid number.');
                }
                break;
            }
            case '6':
                console.log('Goodbye!');
                rl.close();
                return;
            default:
                console.log('Invalid choice.');
        }
    }
}

main().catch(console.error);
