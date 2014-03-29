class Card

  def initialize(suit,value)
    @suit = suit
    @value = value
  end

  def suit()
    @suit
  end

  def value()
    @value
  end

  def to_s
    "#{ @suit } #{ @value }"
  end


end