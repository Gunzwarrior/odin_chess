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
      8.times { arr.push(" ") }
    end
  end

  def pretty_board
    black_first = true
    number_array = %w(8 7 6 5 4 3 2 1)
    number = 0
    print "   a  b  c  d  e  f  g  h "
    puts

    @board.each do |arr|
      print "#{number_array[number]} "
      arr.each do |element|
        black_first == true ? background_color = 44 : background_color = 46 
          if defined?(element.aspect)
          print "\e[#{background_color}m#{element.aspect}\e[0m"
          else
            print "\e[#{background_color};30m#{" "+element+" "}\e[0m"
          end
        black_first == true ? black_first = false : black_first = true
      end
      black_first == true ? black_first = false : black_first = true
      print " #{number_array[number]}"
      number += 1
      puts
    end

    print "   a  b  c  d  e  f  g  h "
    puts
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
