#Utility class for printing stuff
class Print

  def self.heading(title)
    newline
    puts "#{title}"
    line
  end

  def self.line
    puts "--------------------"
  end

  def self.newline
    puts "\n"
  end

  def self.round_over
    puts "\nRound over, press any key to continue to next round"
  end

  def self.game_over
    puts 'All players our of money!'
    puts 'Game Over!'
  end

  def self.player_score(player, player_hand, totals)
    puts "#{player.name} has #{player_hand}\nTotals: #{totals.join(',')}"
  end


end