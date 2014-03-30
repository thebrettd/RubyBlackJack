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

  def initialize(num_players)
    @player_array = []
    @shoe = Shoe.new(6)
    @dealer = Player.new('Dealer')
    num_players.times do
      initialize_player(@player_array.length)
    end
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
    play_all_hands
    resolve_hands
  end

  def resolve_hands

    @current_round_players.each do |player|
      evalute_hands(player)
    end

    @dealer.new_hands
  end

  def evalute_hands(player)

    player.hands.each do |hand|
      puts "Dealer has #{@dealer.hands[0]}"
      result = evaluate_hand(hand)
      if result == Result::Push
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
    dealers_totals = get_hand_values(@dealer.hands[0]).select { |total| total <= 21 }
    players_best = get_hand_values(hand).select { |total| total <= 21}.max
    dealers_best = dealers_totals.max
    dealer_bust = dealers_totals.size == 0
    player_bust = players_best.size == 0

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

  def insurance
    puts "Insurance? (Sucker's bet!)"
  end

  def play_all_hands
    insurance
    do_all_players_turns
    do_dealers_turn
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

  def deal_cards
    deal_card_to_players
    deal_card_to_dealer
    deal_card_to_players
    deal_card_to_dealer
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
    puts "#{player.name}: #{hand} dealer has: #{@dealer.hands[0]}"
    get_player_move(player,hand)
  end

  def get_player_move(player, hand)
    compute_valid_moves(player, hand)

    action_invalid = true
    while action_invalid
      begin

        action = gets.chomp
        action_invalid = invalid_move?(player, action)
      rescue ArgumentError
        #Catches non-number input and betting more than you have
        print "Invalid action #{player.name}, please select a valid action from the list #{valid_moves}: "
      end
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

  def invalid_move?(curr_player, action)
    false
  end

  def do_dealers_turn
    puts "Playing hand for #{@dealer.name}: #{@dealer.hands[0]}"
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

