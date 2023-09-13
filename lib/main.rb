require_relative 'player'
require_relative 'piece'
require_relative 'pawn'
require_relative 'knight'
require_relative 'bishop'
require_relative 'rook'
require_relative 'queen'
require_relative 'king'
require_relative 'board'

player1 = Player.new("One", "white")
player2 = Player.new("Two", "black")

board1 = Board.new(player1, player2)

puts "There is a board, and movable pieces"
puts "Future features will be :"
puts "1. A display of the pieces lost"

board1.pretty_board

puts "\e[30m\u265f\e[0m"

board1.game_loop