require 'lib/player'
require 'lib/card'
require 'lib/suit'
require 'lib/value'
require 'lib/blackjack'

describe Player do

  it 'has a name' do
    game = Blackjack.new(1)
    player = Player.new('Test Player',game.shoe, game.dealer)
    player.name.should eq('Test Player')
  end

  it 'has a bankroll' do
    game = Blackjack.new(1)
    player = Player.new('Test Player',game.shoe, game.dealer)
    player.bankroll.should eq(1000)
  end

  it 'should have an empty hand to start' do
    game = Blackjack.new(1)
    player = Player.new('Test Player',game.shoe, game.dealer)
    player.hands.length.should eq(0)
  end

  it 'should be able to start a new empty hand' do
    game = Blackjack.new(1)
    player = Player.new('Test Player',game.shoe, game.dealer)
    player.new_hands
    player.hands.nil?.should eq(false)
    player.hands[0].cards.size.should eq(0)
  end

  it 'should have a nil wager' do
    game = Blackjack.new(1)
    player = Player.new('Test Player',game.shoe, game.dealer)
    player.current_wager.nil?.should eq(true)
  end

  it 'should have a non-nil wager after placing wagering' do
    game = Blackjack.new(1)
    player = Player.new('Test Player',game.shoe, game.dealer)
    player.place_wager(5)
    player.current_wager.should eq(5)
  end

  it 'bankroll should decrease after placing wagering' do
    game = Blackjack.new(1)
    player = Player.new('Test Player',game.shoe, game.dealer)
    player.place_wager(5)
    player.bankroll.should eq(995)
  end

  it 'hand size should increase after hitting' do
    game = Blackjack.new(1)
    player = Player.new('Test Player',game.shoe, game.dealer)
    player.new_hands

    player.hands[0].add_card(Card.new(Suit::SPADE, Value::TEN), false)
    player.hands[0].cards.size.should eq(1)
  end

end