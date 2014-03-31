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

  it 'hand size should increase after hitting' do
    game = Blackjack.new(1)
    player = Player.new('Test Player',game.shoe, game.dealer)
    player.new_hands

    player.hands[0].add_card(Card.new(Suit::SPADE, Value::TEN), false)
    player.hands[0].cards.size.should eq(1)
  end

end