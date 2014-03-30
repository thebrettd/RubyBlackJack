require 'player'
require 'value'
require 'shoe'
require 'move'
require 'result'

class Blackjack

  #Blackjack should manage the point values for cards, so that card class can be reused for other card games
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

  def initialize(num_players)
    @player_array = []
    @shoe = Shoe.new(6)
    @dealer = Player.new('Dealer')
    num_players.times do
      initialize_player(@player_array.length)
    end
  end

  def dealer
    @dealer
  end

  def self.start
    puts 'Welcome to blackjack!'
    print 'How many players? '
    num_players = get_number_of_players
    game = Blackjack.new(num_players)
    game.play_game
  end

  def self.get_number_of_players
    number_invalid = true
    while number_invalid
      begin
        num_players = Integer(gets.chomp)
        number_invalid = number_valid?(num_players)
      rescue ArgumentError
        print 'Please enter a valid number > 0: '
      end
    end
    num_players
  end

  def self.number_valid?(number)
    if number <= 0
      raise ArgumentError
    end
    false
  end

  def play_game
    while true
      play_round
      puts 'Round over, press any key to continue to next round'
      gets
    end
  end

  def get_hand_values(hand)
    totals = [0]
    hand.cards.each do |card|
      card_points = get_card_value(card)
      if card_points.size == 2
        one_totals = totals.map { |old_total| old_total + card_points[0] }
        eleven_totals = totals.map { |old_total| old_total + card_points[1] }
        totals = one_totals + eleven_totals
      else
        totals.map! { |old_total| old_total + card_points[0] }
      end
    end
    totals.uniq
  end

  def initialize_player(player_num)
      print "Enter player #{player_num}'s name: "
      player = Player.new(gets.chomp)
      @player_array.push(player)
  end

  def play_round
    @current_round_players = []
    get_player_antes
    deal_cards
    do_all_players_turns
    resolve_hands
  end

  def deal_cards
    deal_card_to_players
    deal_card_to_dealer
    deal_card_to_players
    deal_card_to_dealer
  end

  def resolve_hands
    evaluate_dealer_hand
    evalute_all_players_hands
    @dealer.new_hands
  end

  def evalute_all_players_hands
    @current_round_players.each do |player|
      evalute_hands(player)
      player.new_hands
    end
  end

  def evaluate_dealer_hand
    dealer_hand = @dealer.hands[0]
    totals = get_hand_values(dealer_hand)
    while totals.min < 17
      card = @shoe.draw
      dealer_hand.hit(card)
      puts "Dealer draws a #{card}"
      puts "Dealer has #{@dealer.hands[0]}"
      totals = get_hand_values(dealer_hand)
    end

    if dealer_busted
      puts "Dealer busts with #{dealer_hand} values: #{get_hand_values(dealer_hand).join(',')}"
    end

  end

  def dealer_busted
    get_hand_values(@dealer.hands[0]).select { |total| total <= 21 }.size == 0
  end

  def evalute_hands(player)

    player.hands.each do |hand|
      puts "Dealer has #{@dealer.hands[0]}, totals: #{get_hand_values(@dealer.hands[0])}"
      result = evaluate_hand(hand)
      if result == Result::PUSH
        puts "#{player.name} pushes with #{hand}!"
        player.credit(player.current_wager)
      elsif result == Result::WIN
        winnings = player.current_wager * 2
        puts "#{player.name} wins with #{hand}! Winnings: $#{winnings}"
        player.credit(winnings)
      else
        puts "#{player.name} loses! :("
      end
    end
  end

  def evaluate_hand(hand)
    dealers_totals = get_hand_values(@dealer.hands[0])
    player_totals = get_hand_values(hand)
    dealer_bust = dealers_totals.min > 21
    player_bust = player_totals.min > 21
    dealers_best = get_hand_values(@dealer.hands[0]).select { |total| total <= 21}.max
    players_best = get_hand_values(hand).select { |total| total <= 21}.max

    if player_bust
      return Result::LOSE
    elsif dealer_bust
      return Result::WIN
    elsif dealers_best > players_best
      return Result::LOSE
    elsif players_best > dealers_best
      return Result::WIN
    elsif players_best == dealers_best
      return Result::PUSH
    end
  end

  def deal_card(player)
    player.hands[0].hit(@shoe.draw)
  end

  def deal_card_to_dealer
    puts "Dealing to #{@dealer.name}"
    deal_card(@dealer)
  end

  def deal_card_to_players
    @current_round_players.length.times do |curr_player_number|
      curr_player = get_player_by_number(curr_player_number)
      puts "Dealing to #{curr_player.name}"
      deal_card(curr_player)
    end
  end

  def get_player_by_number(curr_player_number)
    @player_array[curr_player_number]
  end

  def do_all_players_turns
    @current_round_players.length.times do |curr_player_number|
      curr_player = get_player_by_number(curr_player_number)
      do_player_turn(curr_player)
    end
  end

  def do_player_turn(player)
    puts "Playing hands for #{player.name}"
    player.hands.each do |hand|
      play_player_hand(player, hand)
    end
  end

  def play_player_hand(player, hand)
    while true
      puts "#{player.name} has: #{hand} totals: #{get_hand_values(hand).join(',')}"
      puts "Dealer has: #{@dealer.hands[0].cards[0]}"
      move = get_player_move(player,hand)

      handle_move(player, hand, move)
      if is_busted?(hand)
        puts "#{player.name}: Busted! :("
        break
      elsif move == Move::STAND || move == Move::DOUBLEDOWN
        break;
      end
    end
  end

  def is_busted?(hand)
    get_hand_values(hand).select { |total| total <= 21}.length == 0
  end

  def get_player_move(player, hand)
    valid_moves = compute_valid_moves(player, hand)

    move_invalid = true
    while move_invalid
      begin
        puts "Enter the first letter of a move from the list: #{valid_moves.join(' ')}"
        input_move = gets.chomp
        move_invalid = invalid_move?(input_move)
      rescue ArgumentError
        #Catches non-number input and betting more than you have
        print "Invalid move #{player.name}, please select a valid move from the list #{valid_moves.join(' ')}: "
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

  def handle_move(player, hand, move)
    case move
      when Move::STAND
        puts "#{player.name} stands!"
      when Move::HIT
        puts "#{player.name} hits!"
        card = @shoe.draw
        puts "#{player.name} drew a #{card}"
        hand.hit(card)
      when Move::DOUBLEDOWN
        player.double_down
        puts "#{player.name} Double's Down! Good Luck!"
        card = @shoe.draw
        puts "#{player.name} drew a #{card}"
        hand.hit(card)
      when Move::SPLIT
        puts "#{player.name} splits! Good Luck!"
      else
        raise ArgumentError
    end
  end

  def compute_valid_moves(player, hand)
    moves = [Move::STAND]

    totals = get_hand_values(hand)
    #Don't allow hit if player has 21 (You're welcome)
    if totals.select{ |total| total == 21}.length >= 1
      #noop
    else
      if totals.select{ |total| total < 21}.length >= 1
        moves.push(Move::HIT)
      end
      #Player can double down if he only has 2 cards and enough money
      if hand.only_two_cards? && player.bankroll >= player.current_wager
        moves.push(Move::DOUBLEDOWN)
        #Player can hit if he has a total < 21
      end
      #Player can split if this hand has exactly 2 two cards and are the same
      if hand.only_two_cards? && hand.cards[0].value == hand.cards[1].value
        moves.push(Move::SPLIT)
      end
    end
    moves
  end

  def get_player_antes
    @player_array.length.times do |curr_player_number|
      curr_player = get_player_by_number(curr_player_number)
      wager_amount = get_wager_for_player(curr_player)

      if wager_amount >= 1
        curr_player.place_wager(wager_amount)
        @current_round_players.push(curr_player)
      else
        puts "#{curr_player.name} abstains"
      end
    end
  end

  def get_wager_for_player(curr_player)
    print "#{curr_player.name} (Bankroll: $#{curr_player.bankroll}) - Enter wager or anything < 1 to abstain: "

    wager_amount, wager_invalid = 0, true
    while wager_invalid
      begin
        wager_amount = Integer(gets.chomp)
        wager_invalid = invalid_wager?(curr_player, wager_amount)
      rescue ArgumentError
        #Catches non-number input and betting more than you have
        print "Invalid wager #{curr_player.name}, please wager <= $#{curr_player.bankroll}: "
      end
    end
    wager_amount
  end

  def get_card_value(card)
    @@point_map[card.value]
  end

  def invalid_wager?(curr_player, wager_amount)
    if wager_amount > curr_player.bankroll
      raise ArgumentError
    end
    false
  end

end

