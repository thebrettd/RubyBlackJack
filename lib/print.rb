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

  def self.game_over
    puts 'All players our of money!'
    puts 'Game Over!'
  end


end