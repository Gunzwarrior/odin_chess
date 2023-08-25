require_relative 'player'
require_relative 'piece'
require_relative 'pawn'
require_relative 'knight'
require_relative 'bishop'
require_relative 'rook'
require_relative 'queen'
require_relative 'king'
require_relative 'board'

puts "Here is a display of the board at the start of the game"
puts

player1 = Player.new("One", "white")
player2 = Player.new("Two", "black")

board1 = Board.new(player1, player2)

board1.pretty_board

puts
puts "Soon you will be able to move pieces"

player1.say_move
board1.move("a1","a3")

# write a general method to move pieces