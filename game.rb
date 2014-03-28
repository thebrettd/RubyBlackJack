require 'value'

class Game

  #Game should manage the point values for cards, so that card class can be reused for other card games
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

  def get_hand_values(hand)
    totals = [0]

    hand.cards.each do |card|
      card_points = get_card_value(card)
      if card_points.size == 2
        one_totals = totals.map { |old_total| old_total + 1 }
        eleven_totals = totals.map { |old_total| old_total + 11 }
        totals = one_totals + eleven_totals
      else
        totals.map! { |old_total| old_total + card_points[0] }
      end
    end

    totals.uniq
  end

  def start
    puts 'Welcome to blackjack!'
    puts 'How many players?'
    Game.new(Integer(gets.chomp))
  end

  def get_card_value(card)
    @@point_map[card.value]
  end

end