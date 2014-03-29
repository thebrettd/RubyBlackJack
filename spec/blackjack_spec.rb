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

    expect {game.invalid_wager?(player, 1001)}.to raise_error
  end

  it 'should allow splitting when both cards are the same' do
    game = Blackjack.new(1)
    player = Player.new('Brett')
    hand = Hand.new

    player.place_wager(5)

    hand.add_card(Card.new(Suit::SPADE, Value::ACE))
    hand.add_card(Card.new(Suit::HEART, Value::ACE))

    game.compute_valid_moves(player, hand).should eq([Move::STAND, Move::HIT, Move::DOUBLEDOWN, Move::SPLIT])
  end

  it 'should not allow splitting when both cards are not the same' do
    game = Blackjack.new(1)
    player = Player.new('Brett')
    hand = Hand.new

    player.place_wager(5)

    hand.add_card(Card.new(Suit::SPADE, Value::KING))
    hand.add_card(Card.new(Suit::HEART, Value::QUEEN))

    game.compute_valid_moves(player, hand).should eq([Move::STAND, Move::HIT, Move::DOUBLEDOWN])
  end

  it 'Should not allow hit if busted' do
    game = Blackjack.new(1)
    player = Player.new('Brett')
    hand = Hand.new

    player.place_wager(5)

    hand.add_card(Card.new(Suit::SPADE, Value::KING))
    hand.add_card(Card.new(Suit::HEART, Value::QUEEN))
    hand.add_card(Card.new(Suit::HEART, Value::QUEEN))

    game.compute_valid_moves(player, hand).should eq([Move::STAND])
  end

  it 'Should not allow double down if more than 2 cards' do
    game = Blackjack.new(1)
    player = Player.new('Brett')
    hand = Hand.new

    player.place_wager(5)

    hand.add_card(Card.new(Suit::SPADE, Value::KING))
    hand.add_card(Card.new(Suit::HEART, Value::QUEEN))
    hand.add_card(Card.new(Suit::HEART, Value::QUEEN))

    game.compute_valid_moves(player, hand).should eq([Move::STAND])
  end

  it 'Soft 20 allow double down' do
    game = Blackjack.new(1)
    player = Player.new('Brett')
    hand = Hand.new

    player.place_wager(5)

    hand.add_card(Card.new(Suit::SPADE, Value::ACE))
    hand.add_card(Card.new(Suit::HEART, Value::NINE))

    game.compute_valid_moves(player, hand).should eq([Move::STAND, Move::HIT, Move::DOUBLEDOWN ])
  end

  it 'Allow hitting if any hand total < 21 (i.e 11 ace busts but 1 ace does not)' do
    game = Blackjack.new(1)
    player = Player.new('Brett')
    hand = Hand.new

    player.place_wager(5)

    hand.add_card(Card.new(Suit::SPADE, Value::ACE))
    hand.add_card(Card.new(Suit::HEART, Value::NINE))
    hand.add_card(Card.new(Suit::SPADE, Value::TWO))

    game.compute_valid_moves(player, hand).should eq([Move::STAND, Move::HIT])
  end

  it 'Doesnt allow hitting if total is 21' do
    game = Blackjack.new(1)
    player = Player.new('Brett')
    hand = Hand.new

    player.place_wager(5)

    hand.add_card(Card.new(Suit::SPADE, Value::ACE))
    hand.add_card(Card.new(Suit::HEART, Value::TEN))

    game.compute_valid_moves(player, hand).should eq([Move::STAND])
  end




end