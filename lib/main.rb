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
puts
puts "The game is playable with two players"
puts "The next big feature will be to be able"
puts "to save and load your game"
p board1.board
p board1.serialize_board
board1.launch_game