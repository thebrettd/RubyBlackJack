require 'player'
require 'value'
require 'shoe'
require 'move'
require 'result'
require 'print'
require 'logic'

class Blackjack

  def dealer
    @dealer
  end

  #Command line driver
  def self.start
    puts "\nWelcome to Brett's Blackjack Casino!"
    print 'How many players? '
    num_players = get_number_of_players
    game = Blackjack.new(num_players)
    game.play_game
  end
  #Command line driver helper
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
  #Command line driver helper
  def self.number_valid?(number)
    if number <= 0
      raise ArgumentError
    end
    false
  end

  def initialize(num_players)
    @player_array = []
    @shoe = Shoe.new(6)
    #todo: use dealer class
    @dealer = Player.new('Dealer')

    Print.newline
    num_players.times do
      initialize_player(@player_array.length)
    end
  end

  def initialize_player(player_num)
    print "Enter player #{player_num}'s name: "
    player = Player.new(gets.chomp)
    @player_array.push(player)
  end

  #Main game loop. Exit when all the money is gone
  def play_game
    while @player_array.select{ |player| player.bankroll > 0 }.length > 0
      play_round
      puts "\nRound over, press any key to continue to next round"
      gets
    end
    game_over
  end

  def game_over
    puts 'All players our of money!'
    puts 'Game Over!'
  end

  def play_round
    @current_round_players = []
    @dealer.new_hands
    get_player_antes
    deal_cards
    do_all_players_turns
    resolve_hands
  end

  #Deal initial cards to all players in the following order
  # All players get one card - exposed
  # Dealer gets one card - hidden
  # All players get one card - exposed
  # Dealer gets one card - hidden
  def deal_cards
    Print.heading('Dealing initial cards')
    deal_card_to_players
    deal_card(@dealer, @shoe.draw, false) #false to hide first dealer card
    deal_card_to_players
    deal_card(@dealer, @shoe.draw, true)
  end

  def resolve_hands
    play_dealer_hand
    evalute_all_players_hands
  end

  def evalute_all_players_hands
    Print.heading('Results')

    dealer_score(Logic.get_hand_values(@dealer.hands[0]))

    @current_round_players.each do |player|
      detemine_results(player)
    end
  end

  #todo: move to dealer class
  def play_dealer_hand
    dealer_hand = @dealer.hands[0]
    Print.heading('Playing dealer hand!')
    totals = Logic.get_hand_values(dealer_hand)
    dealer_score(totals)
    while !Logic.is_busted?(dealer_hand) && (Logic.seventeen_or_above(totals) == false || Logic.contains_soft_seventeen(dealer_hand))
      card = @shoe.draw
      dealer_hand.add_card(card, true)
      #puts "Dealer draws a #{card}"
      totals = Logic.get_hand_values(dealer_hand)
      dealer_score(totals)
    end

    if Logic.is_busted?(dealer_hand)
      puts "Dealer busts with #{dealer_hand} values: #{Logic.get_hand_values(@dealer.hands[0]).join(',')}"
    end

  end

  def dealer_score(totals)
    puts "Dealer has #{@dealer.hands[0]}\nTotals: #{totals.join(',')}"
  end

  def losing_score(hand)
    if is_busted?(hand)
      minimum_score(hand)
    else
      max_under_twenty_two(hand)
    end
  end

  def detemine_results(player)

    player.hands.each do |hand|
      result = evaluate_hand(hand)
      if result == Result::PUSH
        puts "\n#{player.name} pushes with #{hand}! Final Score: #{max_under_twenty_two(hand)}"
        player.credit(player.current_wager)
      elsif result == Result::WIN
        winnings = player.current_wager * 2
        puts "\n#{player.name} wins with #{hand}! Final Score: #{max_under_twenty_two(hand)}\nWinnings: $#{winnings}"
        player.credit(winnings)
      else
        puts "\n #{player.name} loses with #{hand}! Final Score: #{losing_score(hand)}"
      end
    end
  end

  def evaluate_hand(hand)
    dealers_totals = Logic.get_hand_values(@dealer.hands[0])
    player_totals = Logic.get_hand_values(hand)
    dealer_bust = dealers_totals.min > 21
    player_bust = player_totals.min > 21
    dealers_best = Logic.get_hand_values(@dealer.hands[0]).select { |total| total <= 21}.max
    players_best = Logic.get_hand_values(hand).select { |total| total <= 21}.max

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

  #Adds the card to a player (does not draw card)
  def deal_card(player, card, show)
    if show
      puts "Dealing to #{player.name}: #{card}"
    elsif
      puts "Dealing hidden card to #{player.name}"
    end
    player.hands[0].add_card(card, false)
  end


  def deal_card_to_players
    @current_round_players.length.times do |curr_player_number|
      curr_player = get_player_by_number(curr_player_number)
      deal_card(curr_player, @shoe.draw, true)
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
    Print.heading("Playing hands for #{player.name}")
    player.hands.each do |hand|
      play_player_hand(player, hand)
    end
  end

  def play_player_hand(player, hand)
    while true
      puts "#{player.name} has: #{hand} \nTotals: #{Logic.get_hand_values(hand).join(',')}"
      puts "Dealer shows: #{@dealer.hands[0].cards[1]}"
      move = get_player_move(player,hand)

      handle_move(player, hand, move)
      if is_busted?(hand)
        puts "#{player.name}: Busted! :("
        Print.newline
        break
      elsif move == Move::STAND || move == Move::DOUBLEDOWN
        break;
      end
    end
  end


  def get_player_move(player, hand)
    valid_moves = compute_valid_moves(player, hand)

    move_invalid = true
    while move_invalid
      begin
        puts "\nEnter the first letter of a move from the list: #{valid_moves.join(' ')}"
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
        stand(hand, player)
      when Move::HIT
        hit(hand, player)
      when Move::DOUBLEDOWN
        double_down(hand, player)
      when Move::SPLIT
        split_hand(hand, player)

      else
        raise ArgumentError
    end
  end

  def stand(hand, player)
    puts "#{player.name} stands! Totals: #{Logic.get_hand_values(hand).join(",")}"
  end

  def hit(hand, player)
    puts "#{player.name} hits!"
    player.hit(hand,@shoe)
  end

  def double_down(hand, player)
    puts "#{player.name} Double's Down! Good Luck!"
    player.double_down(hand, @shoe)
  end

  def split_hand(hand, player)
    puts "#{player.name} splits! Good Luck!"
    player.split_hand(hand, @shoe)
  end

  def compute_valid_moves(player, hand)
    moves = [Move::STAND]

    totals = Logic.get_hand_values(hand)
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
      if hand.only_two_cards? && hand.cards[0].value == hand.cards[1].value && player.bankroll >= player.current_wager
        moves.push(Move::SPLIT)
      end
    end
    moves
  end

  def get_player_antes
    Print.heading('Wagers')
    @player_array.length.times do |curr_player_number|
      curr_player = get_player_by_number(curr_player_number)
      wager_amount = get_wager_for_player(curr_player)

      if wager_amount >= 1
        curr_player.place_wager(wager_amount)
        curr_player.new_hands
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


  def invalid_wager?(curr_player, wager_amount)
    if wager_amount > curr_player.bankroll
      raise ArgumentError
    end
    false
  end


end

