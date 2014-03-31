class Logic

  def self.seventeen_or_above(totals)
    totals.select { |total| total >= 17 && total <= 21 }.length > 0
  end

  #Return array of all distinct hand values. Ace counts as 1 or 11
  #
  #Loop through each card, and lookup its point value
  #If it returns 2 values (ace):
  # - Add one to every previous total
  # - Add two to every previous total
  # - Combine above two sets to get final total
  #Else it is just one value, add it to every previous total
  def self.get_hand_values(hand)
    totals = [0]
    hand.cards.each do |card|
      card_points = self.get_card_value(card)
      if card_points.size == 2
        #Add a value of 1 to all known sums
        one_totals = totals.map { |old_total| old_total + card_points[0] }
        #Add a value of 11 to all known sums
        eleven_totals = totals.map { |old_total| old_total + card_points[1] }
        #Combine 11-ace and 1-ace totals
        totals = one_totals + eleven_totals
      else
        #Non-ace, just add the value to all known sums
        totals.map! { |old_total| old_total + card_points[0] }
      end
    end
    totals.uniq
  end

  #Same logic as above, but return true if any 11-valued ace results in a sum of 17.
  #Also shortcircuit false if no aces in hand
  def self.contains_soft_seventeen(hand)

    if hand.cards.select { |card| card.value == Value::ACE }.length == 0
      return false
    end

    totals = [0]
    soft_totals = []
    hand.cards.each do |card|
      card_points = self.get_card_value(card)
      if card_points.size == 2
        #Add a value of 1 to all known sums
        one_totals = totals.map { |old_total| old_total + card_points[0] }
        #Add a value of 11 to all known sums
        eleven_totals = totals.map { |old_total| old_total + card_points[1] }
        soft_totals = soft_totals + eleven_totals
        #Combine 11-ace and 1-ace totals
        totals = one_totals + eleven_totals
      else
        #Non-ace, just add the value to all known sums
        totals.map! { |old_total| old_total + card_points[0] }
        soft_totals.map! { |old_total| old_total + card_points[0] }
      end
    end

    return soft_totals.select {|value| value == 17}.length > 0

  end

  def self.max_under_twenty_two(hand)
    Logic.get_hand_values(hand).select{|total| total <= 21 }.max
  end

  def self.minimum_score(hand)
    Logic.get_hand_values(hand).min
  end

  def self.is_busted?(hand)
    Logic.get_hand_values(hand).select { |total| total <= 21}.length == 0
  end

  def self.get_card_value(card)
    @@point_map[card.value]
  end

  #Blackjack game should manage the point values for cards, so that card class can be reused for other card games
  @@point_map = {
      Value::TWO => [2],
      Value::THREE => [3],
      Value::FOUR => [4],
      Value::FIVE => [5],
      Value::SIX => [6],
      Value::SEVEN => [7],
      Value::EIGHT => [8],
      Value::NINE => [9],
      Value::TEN => [10],
      Value::JACK => [10],
      Value::QUEEN => [10],
      Value::KING => [10],
      Value::ACE => [1,11]
  }

end