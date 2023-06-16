require_relative 'player'
require_relative 'piece'
require_relative 'pawn'
require_relative 'knight'
require_relative 'bishop'
require_relative 'rook'
require_relative 'queen'
require_relative 'king'
require_relative 'board'

puts "You'll soon be able to see a chess board."
puts "Stay tuned"

player1 = Player.new("One", "white")
player2 = Player.new("Two", "black")

board1 = Board.new(player1, player2)

board1.pretty_board

# continue playing with the idea of coloring the outlines of pieces with 3x and background with 4x