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

  def hit(hand, shoe)
    card = shoe.draw
    hand.add_card(card, true)
  end

  def add_hand(hand)
    @hands.push(hand)
  end

  def new_hands
    @hands = [Hand.new]
  end

  def double_down(hand, shoe)
    card = shoe.draw
    hand.add_card(card, true)

    @bankroll -= @wager
    @wager += @wager
  end

  def split(hand)
    split_hand = Hand.new
    split_hand.add_card(hand.cards[1], false)
    hand.cards[1] = nil
    add_hand(split_hand)
    @bankroll -= @wager
    @wager += @wager
  end

  def current_wager
    @wager
  end

  def place_wager(amount)
    @wager = amount
    @bankroll -= amount
  end

end