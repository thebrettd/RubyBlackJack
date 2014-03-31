require 'hand'

class Player

  def initialize(name, shoe, dealer)
    @name = name
    @bankroll = 1000
    @hands = []
    @shoe = shoe
    @dealer = dealer
  end

  def name
    @name
  end

  def bankroll
    @bankroll
  end

  def credit(amount)
    @bankroll += amount
  end

  def hands
    @hands
  end

  def hit(hand, shoe)
    card = shoe.draw
    hand.add_card(card, true)
  end

  def add_hand(hand)
    @hands.push(hand)
  end

  def new_hands
    @hands = [Hand.new]
  end

  def double_down(hand, shoe)
    card = shoe.draw
    hand.add_card(card, true)

    @bankroll -= hand.wager
    hand.set_wager(2*hand.wager)
  end

  def split_hand(hand_to_split, shoe)
    @bankroll -= hand_to_split.wager

    new_hand = Hand.new
    new_hand.add_card(hand_to_split.cards[1], false)
    add_hand(new_hand)

    new_hand.set_wager(hand_to_split.wager)

    hand_to_split.cards.delete_at(1)
    hand_to_split.add_card(shoe.draw, true)

    new_hand.add_card(shoe.draw, true)
  end

  def place_wager(amount, hand)
    @bankroll -= amount
    hand.set_wager(amount)
  end

  def play_turn
    Print.heading("Playing hands for #{@name}")
    hand_number = 0
    @hands.each do |hand|
      Print.heading("Playing hand #{hand_number} for #{@name}")
      play_hand(hand)
      hand_number += 1
    end
  end

  def play_hand(hand)
    while true
      puts "#{@name} has: #{hand} \nTotals: #{Logic.get_hand_values(hand).join(',')}"
      puts "Dealer shows: #{@dealer.hands[0].cards[1]}"
      move = get_player_move(hand)

      handle_move(hand, move)
      if Logic.is_busted?(hand)
        puts "#{@name}: Busted! :("
        Print.newline
        break
      elsif move == Move::STAND || move == Move::DOUBLEDOWN
        break;
      end
    end
  end

  def handle_move(hand, move)
    case move
      when Move::STAND
        puts "#{@name} stands! Totals: #{Logic.get_hand_values(hand).join(",")}"
      when Move::HIT
        puts "#{@name} hits!"
        hit(hand, @shoe)
      when Move::DOUBLEDOWN
        puts "#{@name} Double's Down! Good Luck!"
        double_down(hand, @shoe)
      when Move::SPLIT
        puts "#{@name} splits! Good Luck!"
        split_hand(hand, @shoe)
      else
        raise ArgumentError
    end
  end

  def get_player_move(hand)
    valid_moves = Logic.compute_valid_moves(self, hand)

    move_invalid = true
    while move_invalid
      begin
        puts "\nEnter the first letter of a move from the list: #{valid_moves.join(' ')}"
        input_move = gets.chomp
        move_invalid = invalid_move?(input_move)
      rescue ArgumentError
        #Catches non-number input and betting more than you have
        print "Invalid move #{@name}, please select a valid move from the list #{valid_moves.join(' ')}: "
      end
    end

    case input_move.upcase
      when 'S'
        return Move::STAND
      when 'H'
        return Move::HIT
      when 'D'
        return Move::DOUBLEDOWN
      when 'P'
        return Move::SPLIT
      else
        raise ArgumentError
    end

  end

  def invalid_move?(move)
    case move.upcase
      when 'S'
        return false
      when 'H'
        return false
      when 'D'
        return false
      when 'P'
        return false
      else
        return true
    end
  end



end