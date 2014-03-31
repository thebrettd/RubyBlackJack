require 'lib/hand'
require 'lib/card'
require 'lib/suit'
require 'lib/value'

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
    card = Card.new(Suit::SPADE,Value::ACE)
    hand.add_card(card, false)
    hand.size.should eq(1)
  end

  it 'only_two_cards? returns true for exactly 2 card hand' do
    hand = Hand.new
    card = Card.new(Suit::SPADE,Value::ACE)
    hand.add_card(card, false)
    hand.only_two_cards?.should eq(false)
    hand.add_card(card, false)
    hand.only_two_cards?.should eq(true)
    hand.add_card(card, false)
    hand.only_two_cards?.should eq(false)
  end

end