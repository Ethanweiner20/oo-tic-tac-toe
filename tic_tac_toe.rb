# Tic Tac Toe

require 'pry'
require 'yaml'

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

  def play_again?
    answer = nil

    loop do
      message("play_again")
      answer = gets.chomp.downcase
      break if %(y n).include?(answer)
      message("invalid_input")
    end

    answer == 'y'
  end
end

class TTTGame
  include Gameplay

  PLAYER_MARKER = 'X'
  COMPUTER_MARKER = 'O'

  def initialize
    @user = User.new(PLAYER_MARKER)
    @computer = Computer.new(COMPUTER_MARKER)
    @board = Board.new
    @current_player = retrieve_first_player
    @result = nil
  end

  # MAIN METHODS

  def play
    display_welcome_message

    loop do
      reset
      play_match
      break unless play_again?
    end

    display_goodbye_message
  end

  private

  def retrieve_first_player
    [user, computer].sample
  end

  def reset
    board.reset
    self.current_player = retrieve_first_player
    self.result = nil
  end

  def play_match
    display_game_state(clear_screen: false)

    loop do
      take_turn
      break if game_finished?
      alternate_player
    end

    display_result
  end

  def take_turn
    current_player.move(board)
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

  def game_finished?
    !!result
  end

  def alternate_player
    self.current_player = current_player == user ? computer : user
  end

  # DISPLAY METHODS

  def display_game_state(clear_screen: true)
    clear if clear_screen
    prompt("You're #{user.marker}. The computer is #{computer.marker}.\n\n")
    display_tutorial
    display_board
  end

  def display_board
    puts "Current Board:\n\n"
    board.display
    puts
  end

  def display_tutorial
    puts "Position Numbers:\n\n"
    TutorialBoard.new.display
    puts
  end

  def display_result
    prompt(result_message)
  end

  def result_message
    case result
    when :tie then "You tied!"
    when user then "#{user.name} won!"
    when computer then "#{computer.name} won!"
    else raise "The result was never computed!"
    end
  end

  attr_reader :board, :user, :computer
  attr_accessor :result, :current_player
end

class Player
  attr_reader :name, :marker

  def initialize(name, marker)
    @name = name
    @marker = marker
  end

  def move(board, square_number)
    board[square_number] = self
  end
end

class User < Player
  include Gameplay

  def initialize(marker)
    super("Player", marker)
  end

  def move(board)
    super(board, retrieve_square_number(board))
  end

  private

  def retrieve_square_number(board)
    square_number = nil

    loop do
      remaining_square_numbers = board.remaining_square_numbers
      prompt("Choose an empty square "\
             "(#{remaining_square_numbers.map(&:to_s).join(', ')})")
      square_number = gets.chomp.to_i
      break if remaining_square_numbers.include?(square_number)
      message("invalid_input")
    end

    square_number
  end
end

class Computer < Player
  RESPONSE_TIME = 1

  def initialize(marker)
    super("Computer", marker)
  end

  def move(board)
    sleep(RESPONSE_TIME)
    super(board, board.remaining_square_numbers.sample)
  end
end

class Board
  SIZE = 3

  def initialize
    reset
  end

  # RESETTING

  def reset
    self.rows = empty_rows
  end

  # MARKING

  def []=(square_number, player)
    row_index, col_index = (square_number - 1).divmod(SIZE)
    rows[row_index][col_index].mark(player)
  end

  # BOARD STATUS

  def winner
    row_winner || column_winner || diagonal_winner
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
    (0..SIZE - 1).each do |col|
      player = rows[0][col].player
      if player && (0..SIZE - 1).all? { |row| rows[row][col].player == player }
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

  # DISPLAY

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
    (0...SIZE).each_with_object([[], []]) do |row_index, diagonals|
      diagonals[0] << rows[row_index][row_index]
      diagonals[1] << rows[row_index][SIZE - row_index - 1]
    end
  end

  def squares
    rows.flatten
  end

  def empty_rows
    (1..SIZE).map { |_| (1..SIZE).map { |_| Square.new } }
  end

  attr_accessor :rows
end

class TutorialBoard < Board
  def initialize
    @rows = numbered_rows
  end

  def numbered_rows
    (0..SIZE - 1).map do |row_index|
      (1..SIZE).map do |col_number|
        row_index * SIZE + col_number
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