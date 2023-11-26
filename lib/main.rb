# frozen_string_literal: true

require_relative 'player'
require_relative 'piece'
require_relative 'pawn'
require_relative 'knight'
require_relative 'bishop'
require_relative 'rook'
require_relative 'queen'
require_relative 'king'
require_relative 'board'

loop do
  puts 'Enter 1 to play against a human or 2 to play against the computer'
  move_said = gets.chomp
  case move_said
  when '1'
    player1 = Player.new('One', 'white')
    player2 = Player.new('Two', 'black')
    board1 = Board.new(player1, player2)
    puts
    board1.launch_game
    break
  when '2'
    loop do
      puts 'Enter 1 to play as white, 2 to play as black'
      move_said = gets.chomp
      case move_said
      when '1'
        player1 = Player.new('One', 'white')
        player2 = Player.new('Computer', 'black')
        board1 = Board.new(player1, player2)
        puts
        board1.launch_game
        break
      when '2'
        player1 = Player.new('Computer', 'white')
        player2 = Player.new('Two', 'black')
        board1 = Board.new(player1, player2)
        puts
        board1.launch_game
        break
      end
    end
    break
  end
end
