class Player

  def initialize(name)
    @name = name
    @bankroll = 1000
    @hands = []
    @wager = nil
  end

  def name
    @name
  end

  def bankroll
    @bankroll
  end

  def hands
    @hands
  end

  def new_hands
    @hands = []
  end

  def current_wager
    @wager
  end

  def place_wager(amount)
    @wager = amount
    @bankroll -= amount
  end

  def hit(card)
    @hands.push(card)
  end

end