require 'deck'

class Shoe

  def initialize(shoe_size)
    @shoe_size = shoe_size
    @shoe = []
    puts "Creating #{shoe_size}-deck shoe"
    deck_count = 0
    shoe_size.times do
      deck = Deck.new.cards
      puts "Adding deck #{deck_count} to shoe"
      @shoe.concat(deck)
      deck_count += 1
    end
  end

  def draw
    @shoe.pop
  end

  def shoe_size
    @shoe_size
  end

  def cards
    @shoe.length
  end

end