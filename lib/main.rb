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
puts "There is a board, movable pieces and"
puts "a display of lost pieces."
puts "The next big feature will be to handle check."
board1.pretty_board


board1.game_loop