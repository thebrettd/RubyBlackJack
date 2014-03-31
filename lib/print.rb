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


end