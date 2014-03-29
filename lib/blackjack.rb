require 'player'
require 'value'
require 'deck'

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

  def self.start
    puts 'Welcome to blackjack!'
    print 'How many players? '

    number_invalid = true
    while number_invalid
      begin
        num_players = Integer(gets.chomp)
        number_invalid = number_valid?(num_players)
      rescue ArgumentError
        print 'Please enter a valid number > 0: '
      end
    end

    game = Blackjack.new(num_players)
    game.play_game

  end

  def self.number_valid?(number)
    if number <= 0
      raise ArgumentError
    end
    false
  end

  def initialize(num_players)
    @player_array = []
    @deck = Deck.new(6)
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
        one_totals = totals.map { |old_total| old_total + 1 }
        eleven_totals = totals.map { |old_total| old_total + 11 }
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
    puts "everyone wins"
  end

  def insurance
    puts "Insurance (Sucker's bet!)"
  end

  def play_all_hands
    insurance
    play_all_player_hands
    play_dealer_hand
  end

  def deal_card(player)
    player.hit(@deck.draw)
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

  def play_all_player_hands
    @current_round_players.length.times do |curr_player_number|
      curr_player = get_player_by_number(curr_player_number)
      puts "Playing hand for #{curr_player.name}"
    end
  end

  def play_dealer_hand
    puts "Playing hand for #{@dealer.name}"
  end

  def get_player_antes
    @player_array.length.times do |curr_player_number|
      curr_player = get_player_by_number(curr_player_number)
      wager_amount = get_wager_for_player(curr_player)

      if wager_amount > 1
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

