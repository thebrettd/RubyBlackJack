require 'hand'

class Player

  def initialize(name)
    @name = name
    @bankroll = 1000
    @hands = [Hand.new]
    @wager = nil
  end

  def name
    @name
  end

  def bankroll
    @bankroll
  end

  def credit(amount)
    @bankroll += amount
  end

  def hands
    @hands
  end

  def new_hands
    @hands = [[]]
  end

  def double_down
    @wager *= 2
  end

  def current_wager
    @wager
  end

  def place_wager(amount)
    @wager = amount
    @bankroll -= amount
  end

end