class Player

  def initialize(name)
    @name = name
    @bankroll = 1000
    @hand = nil
    @wager = nil
  end

  def name
    @name
  end

  def bankroll
    @bankroll
  end

  def hand
    @hand
  end

  def new_hand
    @hand = []
  end

  def current_wager
    @wager
  end

  def place_wager(amount)
    @wager = amount
    @bankroll -= amount
  end

  def hit(card)
    @hand.push(card)
  end

end