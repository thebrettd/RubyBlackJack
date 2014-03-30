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

  def add_card(card)
    @cards.push(card)
  end

  def only_two_cards?
    @cards.length == 2
  end

  def hit(card)
    @cards.push(card)
  end

  def to_s
    @cards.join(',')
  end

end