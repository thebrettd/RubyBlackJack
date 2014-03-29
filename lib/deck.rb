require 'card'
require 'suit'
require 'value'

class Deck

  def shuffle_deck
    puts 'Shuffling deck'
    [Card.new(Suit::SPADE, Value::ACE)]
  end

  def initialize(shoe_size)
    @deck = shuffle_deck
  end

  def draw
    if @deck.length == 0
      puts 'Deck is empty, shuffling'
      shuffle_deck
    end
  end

end