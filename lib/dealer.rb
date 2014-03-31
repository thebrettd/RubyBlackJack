class Dealer

  def initialize(name, shoe, dealer)
    @name = name
    @hand = []
    @shoe = shoe
  end

  def name
    @name
  end

  def hand
    @hand
  end

  def new_hand
    @hand = Hand.new
  end

end