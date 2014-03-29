require 'lib/hand'
require 'lib/card'

describe Hand do

  it 'cards should not be nil' do
    hand = Hand.new
    hand.cards.nil?.should be_false
  end

  it 'cards should be size 0' do
    hand = Hand.new
    hand.size.should be_zero
  end

  it 'adding a card should increase size' do
    hand = Hand.new
    card = Card.new(0,'Spade')
    hand.add_card(card)
    hand.size.should eq(1)
  end

end