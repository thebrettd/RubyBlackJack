require 'lib/blackjack'
require 'lib/hand'
require 'lib/suit'
require 'lib/value'
require 'lib/card'

describe Blackjack do

  it 'should be able to determine the value of a card' do
    game = Blackjack.new(1)
    queen_spades = Card.new(Suit::SPADE, Value::QUEEN)
    values = Blackjack.get_card_value(queen_spades)
    values.should eq([10])
  end

  it 'should be return 1 or 11 for ace' do
    game = Blackjack.new(1)
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    values = Blackjack.get_card_value(ace_spades)
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

    Blackjack.get_hand_values(hand).should eq([12])
  end

  it 'should compute the correct hand total when ace' do
    game = Blackjack.new(1)
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    six_hearts = Card.new(Suit::HEART, Value::SIX)

    hand = Hand.new
    hand.add_card(ace_spades)
    hand.add_card(six_hearts)

    Blackjack.get_hand_values(hand).should eq([7,17])
  end

  it 'should compute the correct hand total when two ace' do
    game = Blackjack.new(1)
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    six_hearts = Card.new(Suit::HEART, Value::SIX)

    hand = Hand.new
    hand.add_card(ace_spades)
    hand.add_card(six_hearts)
    hand.add_card(ace_spades)

    Blackjack.get_hand_values(hand).should eq([8,18,28])
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

  it 'Same cards should push' do
    game = Blackjack.new(1)
    player = Player.new('Brett')
    hand = Hand.new

    player.place_wager(5)

    ten_spades = Card.new(Suit::SPADE, Value::TEN)
    hand.add_card(ten_spades)
    ten_hearts = Card.new(Suit::HEART, Value::TEN)
    hand.add_card(ten_hearts)

    game.dealer.hands[0].hit(ten_spades)
    game.dealer.hands[0].hit(ten_hearts)

    game.evaluate_hand(hand).should eq(Result::PUSH)
  end

  it 'Players 20 versus 18 should win' do
    game = Blackjack.new(1)
    player = Player.new('Brett')
    hand = Hand.new

    player.place_wager(5)

    ten_hearts = Card.new(Suit::HEART, Value::TEN)
    ten_spades = Card.new(Suit::SPADE, Value::TEN)
    hand.add_card(ten_spades)
    hand.add_card(ten_hearts)

    nine_spades = Card.new(Suit::SPADE, Value::NINE)
    nine_hearts = Card.new(Suit::HEART, Value::NINE)
    game.dealer.hands[0].hit(nine_spades)
    game.dealer.hands[0].hit(nine_hearts)

    game.evaluate_hand(hand).should eq(Result::WIN)
  end

  it 'Player 18 dealer 20 loses' do
    game = Blackjack.new(1)
    player = Player.new('Brett')
    hand = Hand.new

    player.place_wager(5)

    nine_spades = Card.new(Suit::SPADE, Value::NINE)
    nine_hearts = Card.new(Suit::HEART, Value::NINE)
    hand.add_card(nine_spades)
    hand.add_card(nine_hearts)

    ten_hearts = Card.new(Suit::HEART, Value::TEN)
    ten_spades = Card.new(Suit::SPADE, Value::TEN)
    game.dealer.hands[0].hit(ten_hearts)
    game.dealer.hands[0].hit(ten_spades)

    game.evaluate_hand(hand).should eq(Result::LOSE)
  end

  it 'dealer bust player anything should win' do
    game = Blackjack.new(1)
    player = Player.new('Brett')
    hand = Hand.new

    player.place_wager(5)

    ten_spades = Card.new(Suit::SPADE, Value::TEN)
    seven_hearts = Card.new(Suit::HEART, Value::SEVEN)
    hand.add_card(ten_spades)
    hand.add_card(seven_hearts)

    ten_hearts = Card.new(Suit::HEART, Value::TEN)
    six_spade = Card.new(Suit::SPADE, Value::SIX)
    game.dealer.hands[0].hit(ten_hearts)
    game.dealer.hands[0].hit(six_spade)
    game.dealer.hands[0].hit(six_spade)

    game.evaluate_hand(hand).should eq(Result::WIN)
  end

  it 'dealer should stand on hard 17' do
    game = Blackjack.new(1)

    ten_spades = Card.new(Suit::SPADE, Value::TEN)
    seven_hearts = Card.new(Suit::HEART, Value::SEVEN)
    game.dealer.hands[0].add_card(ten_spades)
    game.dealer.hands[0].add_card(seven_hearts)

    game.evaluate_dealer_hand

    game.dealer.hands[0].size.should be == 2
  end

  it 'dealer should hit on 16' do
    game = Blackjack.new(1)

    ten_spades = Card.new(Suit::SPADE, Value::TEN)
    six_hearts = Card.new(Suit::HEART, Value::SIX)
    game.dealer.hands[0].add_card(six_hearts)
    game.dealer.hands[0].add_card(ten_spades)

    game.evaluate_dealer_hand

    game.dealer.hands[0].size.should be >= 3
  end

  it 'can detect soft 17' do
    game = Blackjack.new(1)

    #Simple soft 17
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    six_hearts = Card.new(Suit::HEART, Value::SIX)
    game.dealer.hands[0].add_card(ace_spades)
    game.dealer.hands[0].add_card(six_hearts)
    Blackjack.contains_soft_seventeen(game.dealer.hands[0]).should eq(true)

    #Complex soft 17
    game.dealer.new_hands
    three_spades = Card.new(Suit::HEART, Value::THREE)
    game.dealer.hands[0].add_card(ace_spades)
    game.dealer.hands[0].add_card(three_spades)
    game.dealer.hands[0].add_card(three_spades)
    Blackjack.contains_soft_seventeen(game.dealer.hands[0]).should eq(true)

    #hard 17 that contains 1-valued aces
    game.dealer.new_hands
    five_hearts = Card.new(Suit::HEART, Value::FIVE)
    game.dealer.hands[0].add_card(six_hearts)
    game.dealer.hands[0].add_card(five_hearts)
    game.dealer.hands[0].add_card(five_hearts)
    game.dealer.hands[0].add_card(ace_spades)
    Blackjack.contains_soft_seventeen(game.dealer.hands[0]).should eq(false)

  end


  it 'dealer should hit on soft 17' do
    game = Blackjack.new(1)

    #Dealer hits after simple soft 17
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    six_hearts = Card.new(Suit::HEART, Value::SIX)
    game.dealer.hands[0].add_card(ace_spades)
    game.dealer.hands[0].add_card(six_hearts)
    game.evaluate_dealer_hand
    game.dealer.hands[0].size.should be >= 3

    #Dealer hits after complex soft 17
    game.dealer.new_hands
    three_spades = Card.new(Suit::HEART, Value::THREE)
    game.dealer.hands[0].add_card(ace_spades)
    game.dealer.hands[0].add_card(three_spades)
    game.dealer.hands[0].add_card(three_spades)
    game.evaluate_dealer_hand
    game.dealer.hands[0].size.should be >= 4

    #Dealer doesnt after hard 17 that contains 1-valued aces
    game.dealer.new_hands
    five_hearts = Card.new(Suit::HEART, Value::FIVE)
    game.dealer.hands[0].add_card(six_hearts)
    game.dealer.hands[0].add_card(five_hearts)
    game.dealer.hands[0].add_card(five_hearts)
    game.dealer.hands[0].add_card(ace_spades)
    game.evaluate_dealer_hand
    game.dealer.hands[0].size.should be == 4

  end


end