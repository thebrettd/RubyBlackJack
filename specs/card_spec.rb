require 'lib/blackjack/card'

describe Card, '#intialize' do

  it 'should have a suit and value' do
    card = Card.new(0,'Spade')
    card.suit.nil?.should eq(false)
    card.value.nil?.should eq(false)
  end

end