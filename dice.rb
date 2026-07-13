# dice.rb
require 'time'

DICE_FACES = {
  1 => ["╔═══════╗", "║       ║", "║   ●   ║", "║       ║", "╚═══════╝"],
  2 => ["╔═══════╗", "║ ●     ║", "║       ║", "║     ● ║", "╚═══════╝"],
  3 => ["╔═══════╗", "║ ●     ║", "║   ●   ║", "║     ● ║", "╚═══════╝"],
  4 => ["╔═══════╗", "║ ●   ● ║", "║       ║", "║ ●   ● ║", "╚═══════╝"],
  5 => ["╔═══════╗", "║ ●   ● ║", "║   ●   ║", "║ ●   ● ║", "╚═══════╝"],
  6 => ["╔═══════╗", "║ ● ● ● ║", "║ ● ● ● ║", "║ ● ● ● ║", "╚═══════╝"]
}

class DiceSimulator
  attr_accessor :dice_type, :num_dice

  def initialize
    @dice_type = 6
    @num_dice = 1
    @history = []
    @total_rolls = 0
    @sum_total = 0
    @min_sum = Float::INFINITY
    @max_sum = -Float::INFINITY
    @animation_frames = 8
  end

  def roll
    results = @num_dice.times.map { rand(1..@dice_type) }
    animate(results)
    results
  end

  def animate(final_results)
    system('clear') || system('cls')
    puts "🎲 Rolling dice..."
    sleep 0.3

    @animation_frames.times do |frame|
      temp_results = frame < @animation_frames - 1 ? @num_dice.times.map { rand(1..@dice_type) } : final_results
      display_dice(temp_results, "Rolling...")
      sleep 0.15
      lines = 6 + @num_dice * 5
      print "\033[#{lines}A"
    end
    display_dice(final_results, "Result!")
  end

  def display_dice(results, label)
    puts "\n🎲 #{label}\n"
    dice_lines = results.map { |r| DICE_FACES[r] || DICE_FACES[1] }
    5.times do |line|
      parts = dice_lines.map { |face| face[line] }
      puts parts.join('  ')
    end
    sum = results.sum
    puts "\nResults: #{results.join(', ')}  Sum: #{sum}"
    update_stats(results, sum)
  end

  def update_stats(results, sum)
    @history << { timestamp: Time.now.iso8601, results: results, sum: sum }
    @history.shift if @history.size > 10
    @total_rolls += 1
    @sum_total += sum
    @min_sum = [@min_sum, sum].min
    @max_sum = [@max_sum, sum].max
  end

  def show_history
    if @history.empty?
      puts "No rolls yet."
      return
    end
    puts "\n📜 Roll History (last 10):"
    @history.each_with_index do |entry, i|
      puts "  #{i+1}. #{entry[:timestamp]}: #{entry[:results]} (sum: #{entry[:sum]})"
    end
  end

  def show_stats
    if @total_rolls == 0
      puts "No rolls yet."
      return
    end
    avg = @sum_total.to_f / @total_rolls
    puts "\n📊 Statistics:"
    puts "  Total rolls: #{@total_rolls}"
    puts "  Average sum: #{'%.2f' % avg}"
    puts "  Min sum: #{@min_sum}"
    puts "  Max sum: #{@max_sum}"
  end

  def run
    puts "🎲 Dice Roll Simulator"
    loop do
      puts "\n1. Roll dice"
      puts "2. Show history"
      puts "3. Show statistics"
      puts "4. Change dice type (current: D#{@dice_type})"
      puts "5. Change number of dice (current: #{@num_dice})"
      puts "6. Exit"
      print "Choose: "
      choice = gets.chomp.strip
      case choice
      when '1'
        roll
      when '2'
        show_history
      when '3'
        show_stats
      when '4'
        print "Enter dice type (4, 6, 8, 10, 12, 20, 100): "
        typ = gets.chomp.to_i
        if [4,6,8,10,12,20,100].include?(typ)
          @dice_type = typ
          puts "Dice type changed to D#{@dice_type}"
        else
          puts "Invalid dice type."
        end
      when '5'
        print "Enter number of dice (1-6): "
        num = gets.chomp.to_i
        if num >= 1 && num <= 6
          @num_dice = num
          puts "Number of dice changed to #{@num_dice}"
        else
          puts "Invalid number."
        end
      when '6'
        puts "Goodbye!"
        break
      else
        puts "Invalid choice."
      end
    end
  end
end

DiceSimulator.new.run if __FILE__ == $0
