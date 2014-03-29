require 'lib/card'
require 'lib/suit'
require 'lib/value'

describe Card do

  it 'should have the suit and value that we specified' do
    card = Card.new(Suit::SPADE,Value::ACE)
    card.suit.nil?.should be_false
    card.value.nil?.should be_false

    card.suit.should eq(Suit::SPADE)
    card.value.should eq(Value::ACE)
  end

end