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

pawn1 = Pawn.new(player1)
knight1 = Knight.new(player1)
bishop1 = Bishop.new(player1)
rook1 = Rook.new(player1)
queen1 = Queen.new(player1)
king1 = King.new(player1)
board1 = Board.new(player1, player2)
p pawn1

puts pawn1.aspect
puts knight1.aspect
puts bishop1.aspect
puts rook1.aspect
puts queen1.aspect
puts king1.aspect

p board1
board1.pretty_board

# continue playing with the idea of coloring the outlines of pieces with 3x and background with 4x