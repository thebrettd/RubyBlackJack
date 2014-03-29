require 'lib/blackjack'
require 'lib/hand'
require 'lib/suit'
require 'lib/value'
require 'lib/card'

describe Blackjack do

  it 'should be able to determine the value of a card' do
    game = Blackjack.new(1)
    queen_spades = Card.new(Suit::SPADE, Value::QUEEN)
    values = game.get_card_value(queen_spades)
    values.should eq([10])
  end

  it 'should be return 1 or 11 for ace' do
    game = Blackjack.new(1)
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    values = game.get_card_value(ace_spades)
    values.length.should eq(2)
    values.should eq([1,11])
  end

  it 'should compute the correct hand total when no ace' do
    game = Blackjack.new(1)
    six_spades = Card.new(Suit::SPADE, Value::SIX)
    six_hearts = Card.new(Suit::HEART, Value::SIX)

    hand = Hand.new
    hand.add_card(six_spades)
    hand.add_card(six_hearts)

    game.get_hand_values(hand).should eq([12])
  end

  it 'should compute the correct hand total when ace' do
    game = Blackjack.new(1)
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    six_hearts = Card.new(Suit::HEART, Value::SIX)

    hand = Hand.new
    hand.add_card(ace_spades)
    hand.add_card(six_hearts)

    game.get_hand_values(hand).should eq([7,17])
  end

  it 'should compute the correct hand total when two ace' do
    game = Blackjack.new(1)
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    six_hearts = Card.new(Suit::HEART, Value::SIX)

    hand = Hand.new
    hand.add_card(ace_spades)
    hand.add_card(six_hearts)
    hand.add_card(ace_spades)

    game.get_hand_values(hand).should eq([8,18,28])
  end

  it 'should throw argument error when you wager more than you have' do
    game = Blackjack.new(1)
    player = Player.new('Brett')

    expect {game.validate_wager(player, 1001)}.to raise_error
  end



end