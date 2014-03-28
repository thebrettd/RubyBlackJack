require 'lib/blackjack/card'

describe Card do

  it 'should have a suit and value' do
    card = Card.new(0,'Spade')
    card.suit.nil?.should be_false
    card.value.nil?.should be_false
  end

end