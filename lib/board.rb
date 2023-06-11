# frozen_string_literal: true

# Handling the board characteristics
class Board
  attr_reader :board, :player2, :player1
  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    @board = setup_board
  end

  def empty_board
    array = []
    8.times { array.push([]) }
    black_first = true
    array.each do |arr|
      if black_first
        arr.push("\u2B1B", "\u2B1C", "\u2B1B", "\u2B1C", "\u2B1B", "\u2B1C", "\u2B1B", "\u2B1C")
        black_first = false
      else
        arr.push("\u2B1C", "\u2B1B", "\u2B1C", "\u2B1B", "\u2B1C", "\u2B1B", "\u2B1C", "\u2B1B")
        black_first = true
      end
    end
  end

  def pretty_board
    @board.each do |arr|
      arr.each do |element|
        if element == "\u2B1C" or element == "\u2B1B"
          print element
        else
          print element.aspect
        end
      end
      puts
    end
  end

  def setup_board
    array = empty_board
    array[0] = [Rook.new(player2),
                Knight.new(player2),
                Bishop.new(player2),
                Queen.new(player2),
                King.new(player2),
                Bishop.new(player2),
                Knight.new(player2),
                Rook.new(player2)]
    array[1] = []
    8.times { array[1].push(Pawn.new(player2)) }
    array[7] = [Rook.new(player1),
      Knight.new(player1),
      Bishop.new(player1),
      Queen.new(player1),
      King.new(player1),
      Bishop.new(player1),
      Knight.new(player1),
      Rook.new(player1)]
array[6] = []
8.times { array[6].push(Pawn.new(player1)) }
    array
  end

end
