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

    puts "\n"
    num_players.times do
      initialize_player(@player_array.length)
    end
  end

  def dealer
    @dealer
  end

  def self.start

    puts "\nWelcome to Brett's Blackjack Casino!"
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

  #Return array of all distinct hand values. Ace counts as 1 or 11
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
    heading('Dealing initial cards')
    deal_card_to_players
    deal_card(@dealer, @shoe.draw, false) #false to hide first dealer card
    deal_card_to_players
    deal_card(@dealer, @shoe.draw, true)
  end

  def resolve_hands
    evaluate_dealer_hand
    evalute_all_players_hands
    @dealer.new_hands
  end

  def evalute_all_players_hands
    heading('Results')

    dealer_score(Blackjack.get_hand_values(@dealer.hands[0]))

    @current_round_players.each do |player|
      detemine_results(player)
      player.new_hands
    end
  end

  def heading(title)
    newline
    puts "#{title}"
    line
  end

  def self.seventeen_or_above(totals)
    totals.select { |total| total >= 17 && total <= 21 }.length > 0
  end

  def evaluate_dealer_hand
    heading('Playing dealer hand!')
    totals = Blackjack.get_hand_values(@dealer.hands[0])
    dealer_score(totals)
    while !dealer_busted && (Blackjack.seventeen_or_above(totals) == false || Blackjack.contains_soft_seventeen(@dealer.hands[0]))
      card = @shoe.draw
      @dealer.hands[0].add_card(card, true)
      #puts "Dealer draws a #{card}"
      totals = Blackjack.get_hand_values(@dealer.hands[0])
      dealer_score(totals)

    end

    if dealer_busted
      puts "Dealer busts with #{@dealer.hands[0]} values: #{Blackjack.get_hand_values(@dealer.hands[0]).join(',')}"
    end

  end

  def dealer_score(totals)
    puts "Dealer has #{@dealer.hands[0]}\nTotals: #{totals.join(',')}"
  end

  def line
    puts "--------------------"
  end

  def dealer_busted
    Blackjack.get_hand_values(@dealer.hands[0]).select { |total| total <= 21 }.size == 0
  end

  def detemine_results(player)

    player.hands.each do |hand|
      result = evaluate_hand(hand)
      if result == Result::PUSH
        puts "\n#{player.name} pushes with #{hand}! Totals: #{Blackjack.get_hand_values(hand).join(',')}!"
        player.credit(player.current_wager)
      elsif result == Result::WIN
        winnings = player.current_wager * 2
        puts "\n#{player.name} wins with #{hand}! Totals: #{Blackjack.get_hand_values(hand).join(',')}\nWinnings: $#{winnings}"
        player.credit(winnings)
      else
        puts "\n #{player.name} loses with #{hand}! Totals: #{Blackjack.get_hand_values(hand).join(',')} "
      end
    end
  end

  def evaluate_hand(hand)
    dealers_totals = Blackjack.get_hand_values(@dealer.hands[0])
    player_totals = Blackjack.get_hand_values(hand)
    dealer_bust = dealers_totals.min > 21
    player_bust = player_totals.min > 21
    dealers_best = Blackjack.get_hand_values(@dealer.hands[0]).select { |total| total <= 21}.max
    players_best = Blackjack.get_hand_values(hand).select { |total| total <= 21}.max

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
    heading("Playing hands for #{player.name}")
    player.hands.each do |hand|
      play_player_hand(player, hand)
    end
  end

  def play_player_hand(player, hand)
    while true
      puts "#{player.name} has: #{hand} \nTotals: #{Blackjack.get_hand_values(hand).join(',')}"
      puts "Dealer shows: #{@dealer.hands[0].cards[1]}"
      move = get_player_move(player,hand)

      handle_move(player, hand, move)
      if is_busted?(hand)
        puts "#{player.name}: Busted! :("
        newline
        break
      elsif move == Move::STAND || move == Move::DOUBLEDOWN
        break;
      end
    end
  end

  def newline
    puts "\n"
  end

  def is_busted?(hand)
    Blackjack.get_hand_values(hand).select { |total| total <= 21}.length == 0
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
    puts "#{player.name} stands! Totals: #{Blackjack.get_hand_values(hand).join(",")}"
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
    player.split(hand)
  end

  def compute_valid_moves(player, hand)
    moves = [Move::STAND]

    totals = Blackjack.get_hand_values(hand)
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
    heading('Wagers')
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

  def self.get_card_value(card)
    @@point_map[card.value]
  end

  def invalid_wager?(curr_player, wager_amount)
    if wager_amount > curr_player.bankroll
      raise ArgumentError
    end
    false
  end

end

