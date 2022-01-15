# Tic Tac Toe

require 'yaml'
require 'pry'

module Gameplay
  MESSAGES = YAML.load_file('messages.yml')

  def message(message_key)
    prompt(MESSAGES[message_key])
  end

  def prompt(message)
    puts "==> #{message}"
  end

  def display_welcome_message
    clear
    message("welcome")
  end

  def display_goodbye_message
    message("goodbye")
  end

  def prompt_to_continue
    message("continue_game")
    gets
  end

  def clear
    system('clear')
  end
end

module Nameable
  def retrieve_name
    system('clear')
    name = ''

    loop do
      message("choose_name")
      name = gets.chomp.strip
      break unless name.empty?
      message("invalid_input")
    end

    name
  end
end

module Stringable
  def joinor(nums, delimiter=', ', joiner='or')
    case nums.length
    when 0 then ''
    when 1 then nums.first.to_s
    when 2 then nums.join(" #{joiner} ")
    else "#{nums[0..-2].join(delimiter)}#{delimiter}#{joiner} #{nums.last}"
    end
  end
end

class TTTGame
  include Gameplay

  MARKERS = ['X', 'O']
  WINNING_SCORE = 3

  def initialize
    @user = TTTUser.new(retrieve_user_marker)
    @computer = TTTComputer.new(retrieve_computer_marker)
    @board_size = retrieve_board_size
    @board = Board.new(board_size)
    @current_player = retrieve_first_player
    @result = nil
  end

  # MAIN METHODS

  def play
    display_welcome_message

    loop do
      prompt_to_continue
      reset
      play_match
      break if game_finished?
    end

    display_final_result
    display_goodbye_message
  end

  private

  def game_finished?
    !!final_winner
  end

  def retrieve_user_marker
    clear
    marker = nil

    loop do
      message("choose_marker")
      marker = gets.chomp
      break if MARKERS.include?(marker)
      message("invalid_input")
    end

    marker
  end

  def retrieve_computer_marker
    MARKERS.reject { |marker| marker == user.marker }.first
  end

  def retrieve_board_size
    answer = nil

    loop do
      message("board_size")
      answer = gets.chomp
      break if valid_integer?(answer) && (2..10).to_a.include?(answer.to_i)
      message("invalid_input")
    end

    answer.to_i
  end

  def valid_integer?(input)
    input.to_i.to_s == input
  end

  def retrieve_first_player
    [user, computer].sample
  end

  def reset
    board.reset
    self.current_player = retrieve_first_player
    self.result = nil
  end

  def play_match
    display_game_state

    loop do
      take_turn
      break if match_finished?
      alternate_player
    end

    update_scores
    display_result
  end

  def take_turn
    square_number = current_player.select_square(board)
    board[square_number] = current_player
    display_game_state
    refresh_result
  end

  def refresh_result
    winner = board.winner

    if winner
      self.result = winner
    elsif board.full?
      self.result = :tie
    end
  end

  def update_scores
    case result
    when user then user.increment_score
    when computer then computer.increment_score
    end
  end

  def match_finished?
    !!result
  end

  def alternate_player
    self.current_player = current_player == user ? computer : user
  end

  # DISPLAY METHODS

  def display_game_state(clear_screen: true)
    clear if clear_screen
    display_marker_info
    display_score
    puts
    display_tutorial
    display_board
  end

  def display_marker_info
    prompt("You're #{user.marker}. The computer is #{computer.marker}.")
  end

  def display_board
    puts "Current Board:\n\n"
    board.display
    puts
  end

  def display_tutorial
    puts "Position Numbers:\n\n"
    TutorialBoard.new(board_size).display
    puts
  end

  def display_result
    display_score
    prompt(result_message)
  end

  def display_score
    prompt("The score is #{user.score} (#{user.name}) "\
          "to #{computer.score} (#{computer.name})")
  end

  def result_message
    case result
    when :tie then "You tied!"
    when user then "#{user.name} won!"
    when computer then "#{computer.name} won!"
    else raise "The result was never computed!"
    end
  end

  def display_final_result
    prompt_to_continue
    prompt("#{final_winner.name} is the final winner!")
  end

  def final_winner
    if user.score == WINNING_SCORE
      user
    elsif computer.score == WINNING_SCORE
      computer
    end
  end

  attr_reader :board, :user, :computer, :board_size
  attr_accessor :result, :current_player
end

class TTTPlayer
  attr_reader :name, :marker, :score

  def initialize(name, marker)
    @name = name
    @marker = marker
    @score = 0
  end

  def increment_score
    self.score += 1
  end

  private

  attr_writer :name, :score
end

class TTTUser < TTTPlayer
  include Gameplay, Nameable, Stringable

  def initialize(marker)
    super(retrieve_name, marker)
  end

  def select_square(board)
    square_number = nil
    square_numbers = board.remaining_square_numbers

    loop do
      prompt("Choose an empty square "\
             "(#{joinor(square_numbers)})")
      square_number = gets.chomp.to_i
      break if square_numbers.include?(square_number)
      message("invalid_input")
    end

    square_number
  end
end

class TTTComputer < TTTPlayer
  RESPONSE_TIME = 1

  def initialize(marker)
    super('Computer', marker)
  end

  def select_square(board)
    sleep(RESPONSE_TIME)

    board.square_to_win(self) || # Offensive
      board.square_to_lose(self) || # Defensive
      board.remaining_middle_square ||
      board.remaining_square_numbers.sample
  end
end

class Board
  def initialize(size)
    @size = size
    reset
  end

  # Copying

  def copy
    (0...size).each_with_object(self.class.new(size)) do |row_index, new_board|
      (0...size).each do |col_index|
        new_board.rows[row_index][col_index] = rows[row_index][col_index].dup
      end
    end
  end

  def reset
    self.rows = empty_rows
  end

  def []=(square_number, player)
    row_index, col_index = (square_number - 1).divmod(size)
    rows[row_index][col_index].mark(player)
  end

  # BOARD STATUS

  def winner
    row_winner || column_winner || diagonal_winner
  end

  def square_to_win(player)
    remaining_square_numbers.find do |square_number|
      next_board = copy
      next_board[square_number] = player
      next_board.winner == player
    end
  end

  def square_to_lose(player)
    other_player = squares.map(&:player).reject { |p| p == player }.first
    square_to_win(other_player) if other_player
  end

  def remaining_middle_square
    remaining_square_numbers.find do |square_number|
      square_number == (size**2 / 2.0).ceil
    end
  end

  private

  def row_winner
    rows.each do |row|
      player = row[0].player
      if player && row.all? { |square| square.player == player }
        return player
      end
    end
    nil
  end

  def column_winner
    (0...size).each do |col|
      player = rows[0][col].player
      if player && (0...size).all? { |row| rows[row][col].player == player }
        return player
      end
    end
    nil
  end

  def diagonal_winner
    diagonals.each do |diagonal|
      player = diagonal[0].player
      if player && diagonal.all? { |square| square.player == player }
        return player
      end
    end
    nil
  end

  # BOARD DISPLAY

  public

  def display
    rows.each do |row|
      display_row(row)
    end
  end

  private

  def display_row(row)
    print "|"
    row.each { |square| print "#{square}|" }
    print "\n"
  end

  # AUXILIARY METHODS

  public

  def remaining_square_numbers
    squares.map.with_index do |square, index|
      index + 1 if square.unmarked?
    end.compact
  end

  def full?
    squares.none?(&:unmarked?)
  end

  private

  def diagonals
    (0...size).each_with_object([[], []]) do |row_index, diagonals|
      diagonals[0] << rows[row_index][row_index]
      diagonals[1] << rows[row_index][size - row_index - 1]
    end
  end

  def squares
    rows.flatten
  end

  def empty_rows
    (1..size).map { |_| (1..size).map { |_| Square.new } }
  end

  protected

  attr_reader :size
  attr_accessor :rows
end

class TutorialBoard < Board
  def initialize(size)
    @size = size
    @rows = numbered_rows
  end

  def numbered_rows
    (0...size).map do |row_index|
      (1..size).map do |col_number|
        row_index * size + col_number
      end
    end
  end
end

class Square
  attr_reader :player

  def initialize(player = nil)
    @player = player
  end

  def unmarked?
    !player
  end

  def mark(player)
    self.player = player
  end

  def to_s
    return '_' unless player
    player.marker
  end

  private

  attr_writer :player
end

TTTGame.new.play
