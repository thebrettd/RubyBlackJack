class Hand

  def initialize()
    @cards = []
  end

  def cards
    @cards
  end

  def size
    @cards.length
  end

  def add_card(card, print)
    @cards.push(card)
    if print
      puts "Drew a #{card}, \nTotals: #{Blackjack.get_hand_values(self).join(",")}"
    end
  end

  def only_two_cards?
    @cards.length == 2
  end

  def to_s
    @cards.join(',')
  end

end