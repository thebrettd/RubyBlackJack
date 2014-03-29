require 'lib/player'
require 'lib/card'
require 'lib/suit'
require 'lib/value'

describe Player do

  it 'has a name' do
    player = Player.new('Test Player')
    player.name.should eq('Test Player')
  end

  it 'has a bankroll' do
    player = Player.new('Test Player')
    player.bankroll.should eq(1000)
  end

  it 'should have an empty hand to start' do
    player = Player.new('Test Player')
    player.hand.empty?.should eq(true)
  end

  it 'should be able to start a new empty hand' do
    player = Player.new('Test Player')
    player.new_hand
    player.hand.nil?.should eq(false)
    player.hand.size.should eq(0)
  end

  it 'should have a nil wager' do
    player = Player.new('Test Player')
    player.current_wager.nil?.should eq(true)
  end

  it 'should have a non-nil wager after placing wagering' do
    player = Player.new('Test Player')
    player.place_wager(5)
    player.current_wager.should eq(5)
  end

  it 'bankroll should decrease after placing wagering' do
    player = Player.new('Test Player')
    player.place_wager(5)
    player.bankroll.should eq(995)
  end

  it 'hand size should increase after hitting' do
    player = Player.new('Test Player')
    player.new_hand

    player.hit(Card.new(Suit::SPADE, Value::TEN))
    player.hand.size.should eq(1)
  end

end