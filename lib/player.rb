require 'hand'

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

  def split_hand(hand_to_split, shoe)
    @bankroll -= @wager
    @wager += @wager

    new_hand = Hand.new
    new_hand.add_card(hand_to_split.cards[1], false)
    add_hand(new_hand)

    hand_to_split.cards.delete_at(1)
    hand_to_split.add_card(shoe.draw, true)

    new_hand.add_card(shoe.draw, true)
  end

  def current_wager
    @wager
  end

  def place_wager(amount)
    @wager = amount
    @bankroll -= amount
  end

end