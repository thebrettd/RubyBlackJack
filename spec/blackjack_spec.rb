require 'lib/blackjack'
require 'lib/hand'
require 'lib/suit'
require 'lib/value'
require 'lib/card'
require 'lib/logic'

describe Blackjack do

  it 'should be able to determine the value of a card' do
    game = Blackjack.new(1)
    queen_spades = Card.new(Suit::SPADE, Value::QUEEN)
    values = Logic.get_card_value(queen_spades)
    values.should eq([10])
  end

  it 'should be return 1 or 11 for ace' do
    game = Blackjack.new(1)
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    values = Logic.get_card_value(ace_spades)
    values.length.should eq(2)
    values.should eq([1,11])
  end

  it 'should compute the correct hand total when no ace' do
    game = Blackjack.new(1)
    six_spades = Card.new(Suit::SPADE, Value::SIX)
    six_hearts = Card.new(Suit::HEART, Value::SIX)

    hand = Hand.new
    hand.add_card(six_spades, false)
    hand.add_card(six_hearts, false)

    Logic.get_hand_values(hand).should eq([12])
  end

  it 'should compute the correct hand total when ace' do
    game = Blackjack.new(1)
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    six_hearts = Card.new(Suit::HEART, Value::SIX)

    hand = Hand.new
    hand.add_card(ace_spades, false)
    hand.add_card(six_hearts, false)

    Logic.get_hand_values(hand).should eq([7,17])
  end

  it 'should compute the correct hand total when two ace' do
    game = Blackjack.new(1)
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    six_hearts = Card.new(Suit::HEART, Value::SIX)

    hand = Hand.new
    hand.add_card(ace_spades, false)
    hand.add_card(six_hearts, false)
    hand.add_card(ace_spades, false)

    Logic.get_hand_values(hand).should eq([8,18,28])
  end

  it 'should throw argument error when you wager more than you have' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)

    expect {game.invalid_wager?(player, 1001)}.to raise_error
  end

  it 'should allow splitting when both cards are the same' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5, hand)

    hand.add_card(Card.new(Suit::SPADE, Value::ACE), false)
    hand.add_card(Card.new(Suit::HEART, Value::ACE), false)

    Logic.compute_valid_moves(player, hand).should eq([Move::STAND, Move::HIT, Move::DOUBLEDOWN, Move::SPLIT])
  end

  it 'should not allow splitting when the player lacks funds' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(1000, hand)

    hand.add_card(Card.new(Suit::SPADE, Value::ACE), false)
    hand.add_card(Card.new(Suit::HEART, Value::ACE), false)

    Logic.compute_valid_moves(player, hand).should eq([Move::STAND, Move::HIT])
  end

  it 'should not allow splitting when both cards are not the same' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5, hand)

    hand.add_card(Card.new(Suit::SPADE, Value::KING), false)
    hand.add_card(Card.new(Suit::HEART, Value::QUEEN), false)

    Logic.compute_valid_moves(player, hand).should eq([Move::STAND, Move::HIT, Move::DOUBLEDOWN])
  end

  it 'splitting should increase the number of players hands by one' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    player.hands.size.should be == 0

    hand = Hand.new
    player.add_hand(hand)
    hand.add_card(Card.new(Suit::SPADE, Value::QUEEN), false)
    hand.add_card(Card.new(Suit::HEART, Value::QUEEN), false)
    player.hands.size.should be == 1

    player.place_wager(5, hand)


    player.split_hand(hand,game.shoe)
    player.hands.size.should be == 2
  end

  it 'splitting should decrease the bankroll by initial wager' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5, hand)

    hand.add_card(Card.new(Suit::SPADE, Value::KING), false)
    hand.add_card(Card.new(Suit::HEART, Value::QUEEN), false)

    player.split_hand(hand,game.shoe)
    player.bankroll.should be == 990
  end

  it 'Should not allow hit if busted' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5, hand)

    hand.add_card(Card.new(Suit::SPADE, Value::KING), false)
    hand.add_card(Card.new(Suit::HEART, Value::QUEEN), false)
    hand.add_card(Card.new(Suit::HEART, Value::QUEEN), false)

    Logic.compute_valid_moves(player, hand).should eq([Move::STAND])
  end

  it 'Should not allow double down if more than 2 cards' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5, hand)

    hand.add_card(Card.new(Suit::SPADE, Value::KING), false)
    hand.add_card(Card.new(Suit::HEART, Value::QUEEN), false)
    hand.add_card(Card.new(Suit::HEART, Value::QUEEN), false)

    Logic.compute_valid_moves(player, hand).should eq([Move::STAND])
  end

  it 'Soft 20 allow double down' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5, hand)

    hand.add_card(Card.new(Suit::SPADE, Value::ACE), false)
    hand.add_card(Card.new(Suit::HEART, Value::NINE), false)

    Logic.compute_valid_moves(player, hand).should eq([Move::STAND, Move::HIT, Move::DOUBLEDOWN ])
  end

  it 'Allow hitting if any hand total < 21 (i.e 11 ace busts but 1 ace does not)' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5, hand)

    hand.add_card(Card.new(Suit::SPADE, Value::ACE), false)
    hand.add_card(Card.new(Suit::HEART, Value::NINE), false)
    hand.add_card(Card.new(Suit::SPADE, Value::TWO), false)

    Logic.compute_valid_moves(player, hand).should eq([Move::STAND, Move::HIT])
  end

  it 'Doesnt allow hitting if total is 21' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5, hand)

    hand.add_card(Card.new(Suit::SPADE, Value::ACE), false)
    hand.add_card(Card.new(Suit::HEART, Value::TEN), false)

    Logic.compute_valid_moves(player, hand).should eq([Move::STAND])
  end

  it 'Same cards should push' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5, hand)

    ten_spades = Card.new(Suit::SPADE, Value::TEN)
    hand.add_card(ten_spades, false)
    ten_hearts = Card.new(Suit::HEART, Value::TEN)
    hand.add_card(ten_hearts, false)

    game.dealer.new_hand
    game.dealer.hand.add_card(ten_spades, false)
    game.dealer.hand.add_card(ten_hearts, false)

    Logic.evaluate_hand(hand, game.dealer.hand).should eq(Result::PUSH)
  end

  it 'Players 20 versus 18 should win' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5, hand)

    ten_hearts = Card.new(Suit::HEART, Value::TEN)
    ten_spades = Card.new(Suit::SPADE, Value::TEN)
    hand.add_card(ten_spades, false)
    hand.add_card(ten_hearts, false)

    nine_spades = Card.new(Suit::SPADE, Value::NINE)
    nine_hearts = Card.new(Suit::HEART, Value::NINE)
    game.dealer.new_hand
    game.dealer.hand.add_card(nine_spades, false)
    game.dealer.hand.add_card(nine_hearts, false)

    Logic.evaluate_hand(hand, game.dealer.hand).should eq(Result::WIN)
  end

  it 'Player 18 dealer 20 loses' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5, hand)

    nine_spades = Card.new(Suit::SPADE, Value::NINE)
    nine_hearts = Card.new(Suit::HEART, Value::NINE)
    hand.add_card(nine_spades, false)
    hand.add_card(nine_hearts, false)

    ten_hearts = Card.new(Suit::HEART, Value::TEN)
    ten_spades = Card.new(Suit::SPADE, Value::TEN)
    game.dealer.new_hand
    game.dealer.hand.add_card(ten_hearts, false)
    game.dealer.hand.add_card(ten_spades, false)

    Logic.evaluate_hand(hand, game.dealer.hand).should eq(Result::LOSE)
  end

  it 'dealer bust player anything should win' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5, hand)

    ten_spades = Card.new(Suit::SPADE, Value::TEN)
    seven_hearts = Card.new(Suit::HEART, Value::SEVEN)
    hand.add_card(ten_spades, false)
    hand.add_card(seven_hearts, false)

    ten_hearts = Card.new(Suit::HEART, Value::TEN)
    six_spade = Card.new(Suit::SPADE, Value::SIX)
    game.dealer.new_hand
    game.dealer.hand.add_card(ten_hearts, false)
    game.dealer.hand.add_card(six_spade, false)
    game.dealer.hand.add_card(six_spade, false)

    Logic.evaluate_hand(hand, game.dealer.hand).should eq(Result::WIN)
  end

  it 'dealer should stand on hard 17' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)

    ten_spades = Card.new(Suit::SPADE, Value::TEN)
    seven_hearts = Card.new(Suit::HEART, Value::SEVEN)
    game.dealer.new_hand
    game.dealer.hand.add_card(ten_spades, false)
    game.dealer.hand.add_card(seven_hearts, false)

    game.current_round_players.push(player)
    game.dealer.play_hand

    game.dealer.hand.size.should be == 2
  end

  it 'dealer should hit on 16' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)

    ten_spades = Card.new(Suit::SPADE, Value::TEN)
    six_hearts = Card.new(Suit::HEART, Value::SIX)
    game.dealer.new_hand
    game.dealer.hand.add_card(six_hearts, false)
    game.dealer.hand.add_card(ten_spades, false)

    game.current_round_players.push(player)

    game.dealer.play_hand

    game.dealer.hand.size.should be >= 3
  end

  it 'can detect soft 17' do
    game = Blackjack.new(1)

    #Simple soft 17
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    six_hearts = Card.new(Suit::HEART, Value::SIX)
    game.dealer.new_hand
    game.dealer.hand.add_card(ace_spades, false)
    game.dealer.hand.add_card(six_hearts, false)
    Logic.contains_soft_seventeen(game.dealer.hand).should eq(true)

    #Complex soft 17
    game.dealer.new_hand
    three_spades = Card.new(Suit::HEART, Value::THREE)
    game.dealer.hand.add_card(ace_spades, false)
    game.dealer.hand.add_card(three_spades, false)
    game.dealer.hand.add_card(three_spades, false)
    Logic.contains_soft_seventeen(game.dealer.hand).should eq(true)

    #hard 17 that contains 1-valued aces
    game.dealer.new_hand
    five_hearts = Card.new(Suit::HEART, Value::FIVE)
    game.dealer.hand.add_card(six_hearts, false)
    game.dealer.hand.add_card(five_hearts, false)
    game.dealer.hand.add_card(five_hearts, false)
    game.dealer.hand.add_card(ace_spades, false)
    Logic.contains_soft_seventeen(game.dealer.hand).should eq(false)

    #Dealer has  two of hearts, ace of clubs, four of diamonds, nine of hearts
    game.dealer.new_hand
    two_hearts = Card.new(Suit::HEART, Value::TWO)
    four_hearts = Card.new(Suit::HEART, Value::FOUR)
    nine_hearts = Card.new(Suit::HEART, Value::NINE)
    game.dealer.hand.add_card(two_hearts, false)
    game.dealer.hand.add_card(ace_spades, false)
    game.dealer.hand.add_card(four_hearts, false)
    game.dealer.hand.add_card(nine_hearts, false)
    Logic.contains_soft_seventeen(game.dealer.hand).should eq(false)

  end


  it 'dealer should hit on soft 17' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    game.current_round_players.push(player)

    #Dealer hits after simple soft 17
    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    six_hearts = Card.new(Suit::HEART, Value::SIX)
    game.dealer.new_hand
    game.dealer.hand.add_card(ace_spades, false)
    game.dealer.hand.add_card(six_hearts, false)
    game.dealer.play_hand
    game.dealer.hand.size.should be >= 3

    #Dealer hits after complex soft 17
    game.dealer.new_hand
    three_spades = Card.new(Suit::HEART, Value::THREE)
    game.dealer.hand.add_card(ace_spades, false)
    game.dealer.hand.add_card(three_spades, false)
    game.dealer.hand.add_card(three_spades, false)
    game.dealer.play_hand
    game.dealer.hand.size.should be >= 4

    #Dealer doesnt after hard 17 that contains 1-valued aces
    game.dealer.new_hand
    five_hearts = Card.new(Suit::HEART, Value::FIVE)
    game.dealer.hand.add_card(six_hearts, false)
    game.dealer.hand.add_card(five_hearts, false)
    game.dealer.hand.add_card(five_hearts, false)
    game.dealer.hand.add_card(ace_spades, false)
    game.dealer.play_hand
    game.dealer.hand.size.should be == 4

    #Dealer has  two of hearts, ace of clubs, four of diamonds, nine of hearts
    game.dealer.new_hand
    two_hearts = Card.new(Suit::HEART, Value::TWO)
    four_hearts = Card.new(Suit::HEART, Value::FOUR)
    nine_hearts = Card.new(Suit::HEART, Value::NINE)
    game.dealer.hand.add_card(two_hearts, false)
    game.dealer.hand.add_card(ace_spades, false)
    game.dealer.hand.add_card(four_hearts, false)
    game.dealer.hand.add_card(nine_hearts, false)
    game.dealer.play_hand
    game.dealer.hand.size.should be >= 5
  end

  it 'dealer blackjack player blackjack should push' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5,hand)

    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    queen_hearts = Card.new(Suit::HEART, Value::QUEEN)
    hand.add_card(ace_spades, false)
    hand.add_card(queen_hearts, false)

    game.dealer.new_hand
    game.dealer.hand.add_card(ace_spades, false)
    game.dealer.hand.add_card(queen_hearts, false)

    Logic.evaluate_hand(hand, game.dealer.hand).should eq(Result::PUSH)
  end

  it 'player blackjack dealer twentyone should blackjack' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5,hand)

    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    queen_hearts = Card.new(Suit::HEART, Value::QUEEN)
    hand.add_card(ace_spades, false)
    hand.add_card(queen_hearts, false)

    seven_hearts = Card.new(Suit::HEART, Value::SEVEN)
    game.dealer.new_hand
    game.dealer.hand.add_card(seven_hearts, false)
    game.dealer.hand.add_card(seven_hearts, false)
    game.dealer.hand.add_card(seven_hearts, false)

    Logic.evaluate_hand(hand, game.dealer.hand).should eq(Result::BLACKJACK)
  end

  it 'dealer blackjack player twentyone should lose' do
    game = Blackjack.new(1)
    player = Player.new('Brett', game.shoe, game.dealer)
    hand = Hand.new

    player.place_wager(5,hand)

    seven_hearts = Card.new(Suit::HEART, Value::SEVEN)
    hand.add_card(seven_hearts, false)
    hand.add_card(seven_hearts, false)
    hand.add_card(seven_hearts, false)

    ace_spades = Card.new(Suit::SPADE, Value::ACE)
    queen_hearts = Card.new(Suit::HEART, Value::QUEEN)
    game.dealer.new_hand
    game.dealer.hand.add_card(ace_spades, false)
    game.dealer.hand.add_card(queen_hearts, false)

    Logic.evaluate_hand(hand, game.dealer.hand).should eq(Result::LOSE)
  end

end