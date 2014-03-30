require 'lib/shoe'

describe Shoe do

  it 'Should have 52 * number of deck cards in the shoe' do
    shoe = Shoe.new(1)
    shoe.shoe_size.should eq(1)
    shoe.cards.should eq(52)

    shoe6 = Shoe.new(6)
    shoe6.shoe_size.should eq(6)
    shoe6.cards.should eq(6*52)
  end

  it 'card count should decrease by one after drawing' do
    shoe = Shoe.new(1)
    shoe.draw
    shoe.cards.should eq(51)
  end

  it 'Shoe refreshes when <= 20 cards in shoe' do
    shoe = Shoe.new(1)
    32.times do
      shoe.draw
    end
    shoe.draw
    shoe.cards.should eq(51)
  end

end