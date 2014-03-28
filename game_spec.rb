require 'game'
require 'hand'
require 'suit'
require 'value'
require 'card'

describe Game do

  it 'should be able to determine the value of a card' do
    game = Game.new
    queen_spades = Card.new(Suit::SPADE, Value::QUEEN)
    values = game.get_card_value(queen_spades)
    values.should eq([10])
  end

  it 'should be return 1 or 11 for ace' do
    game = Game.new
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    values = game.get_card_value(ace_spades)
    values.length.should eq(2)
    values.should eq([1,11])
  end

  it 'should compute the correct hand total when no ace' do
    game = Game.new
    six_spades = Card.new(Suit::SPADE, Value::SIX)
    six_hearts = Card.new(Suit::HEART, Value::SIX)

    hand = Hand.new
    hand.add_card(six_spades)
    hand.add_card(six_hearts)

    game.get_hand_values(hand).should eq([12])
  end

  it 'should compute the correct hand total when ace' do
    game = Game.new
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    six_hearts = Card.new(Suit::HEART, Value::SIX)

    hand = Hand.new
    hand.add_card(ace_spades)
    hand.add_card(six_hearts)

    game.get_hand_values(hand).should eq([7,17])
  end

  it 'should compute the correct hand total when two ace' do
    game = Game.new
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    six_hearts = Card.new(Suit::HEART, Value::SIX)

    hand = Hand.new
    hand.add_card(ace_spades)
    hand.add_card(six_hearts)
    hand.add_card(ace_spades)

    game.get_hand_values(hand).should eq([8,18,28])
  end



end