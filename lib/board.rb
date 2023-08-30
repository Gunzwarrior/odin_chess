# frozen_string_literal: true

# Handling the board characteristics
class Board
  attr_reader :board, :player2, :player1, :current_player
  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    @board = setup_board
    @current_player = player1
  end

  def empty_board
    array = []
    8.times { array.push([]) }
    array.each do |arr|
      8.times { arr.push(" ") }
    end
  end

  def move(start, finish)
    start_array = board_array(start)
    finish_array = board_array(finish)
    board[finish_array[0]][finish_array[1]] = board[start_array[0]][start_array[1]]
    board[start_array[0]][start_array[1]] = ' '
    pretty_board
  end

  def board_array(string)
    array = string.split("")
    x_hash = { a: 0, b: 1, c: 2, d: 3,
               e: 4, f: 5, g: 6, h: 7 }
    y_array = [0, 7, 6, 5, 4, 3, 2, 1, 0]
    [y_array[array[1].to_i], x_hash[array[0].to_sym]]
  end

  def which_piece(string)
    array = board_array(string)
    board[array[0]][array[1]].class
  end

  def which_rule(piece, start, finish)
    if piece == Rook
      rule_rook(start, finish)
    elsif piece == Bishop
      rule_bishop(start, finish)
    elsif piece == Queen
      rule_queen(start,finish)
    elsif piece == Pawn
      rule_pawn(start,finish)
    end
  end

  def rule_rook(start, finish)
    return true if start[0] == finish[0] || start[1] == finish[1]

    false
  end

  def rule_bishop(start, finish)
    start_array = board_array(start)
    finish_array = board_array(finish)
    return true if diagonal_path?(start_array, finish_array)

    false
  end

  def rule_queen(start,finish)
    return true if rule_rook(start,finish)
    return true if rule_bishop(start,finish)
    
    false
  end

  def rule_pawn(start, finish)
    start_array = board_array(start)
    finish_array = board_array(finish)
    number_forward = board[start_array[0]][start_array[1]].color == "white" ? 1 : -1
    go_forward = start_array[0]-finish_array[0] == number_forward
    go_one_step_sideway = (start_array[1]-finish_array[1]).abs == 1
    enemy_present = !empty?(finish) && board[finish_array[0]][finish_array[1]].color != board[start_array[0]][start_array[1]].color
    return true if start[0] == finish[0] && go_forward && empty?(finish)
    return true if go_forward && go_one_step_sideway && enemy_present

    false
  end

  def path_blocked?(start, finish)
    start_array = board_array(start)
    finish_array = board_array(finish)

    if start_array[0] == finish_array[0]
      path = make_line_path(start_array, finish_array)
    elsif start_array[1] == finish_array[1]
      path = make_column_path(start_array, finish_array)
    elsif diagonal_path?(start_array, finish_array)
      path = make_diagonal_path(start_array, finish_array)
    else
      false
    end
    !empty_path?(path)
  end

  def diagonal_path?(start, finish)
  (start[0]-finish[0]).abs == (start[1]-finish[1]).abs
  end

  def make_diagonal_path(start, finish)
    path = []
    if start[0] < finish[0]
      begin_x_number = start[0]
      end_x_number = finish[0]
    else
      begin_x_number = finish[0]
      end_x_number = start[0]
    end
    if start[1] < finish[1]
      begin_y_number = start[1]
    else
      begin_y_number = finish[1]
    end
    for i in begin_x_number...end_x_number-1
      path.push([begin_x_number+1,begin_y_number+1])
      begin_x_number+=1
      begin_y_number+=1
    end
    path
  end

  def make_line_path(start, finish)
    path = []
    if start[1] < finish[1]
      begin_number = start[1]
      end_number = finish[1]
    else
      begin_number = finish[1]
      end_number = start[1]
    end
    for i in begin_number...end_number-1
      path.push([start[0],begin_number+1])
      begin_number+=1
    end
    path
  end

  def make_column_path(start, finish)
    path = []
    if start[0] < finish[0]
      begin_number = start[0]
      end_number = finish[0]
    else
      begin_number = finish[0]
      end_number = start[0]
    end
    for i in begin_number...end_number-1
      path.push([begin_number+1, start[1]])
      begin_number+=1
    end
    path
  end

  def empty_path?(path)
    return true if path.length.zero?

    path.each do |element|
      return false unless board[element[0]][element[1]] == ' '
    end
    true
  end

  def which_color(string)
    array = board_array(string)
    board[array[0]][array[1]].color
  end

  def empty?(string)
    array = board_array(string)
    board[array[0]][array[1]] == ' '
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

  def game_loop
    loop do
      move_said = current_player.say_move
      break if move_said == 'exit'
      if move_validation(move_said)
        move(move_said.split(' ')[0], move_said.split(' ')[1])
        player_swap
      end
    end
  end  

  def player_swap
    @current_player == player1 ? @current_player = player2 : @current_player = player1
  end 

  def move_validation(move_said)
    return false unless current_player.valid_move?(move_said)
    move_array = move_said.split(' ')
    return false if move_array[0] == move_array[1]
    return false if empty?(move_array[0])
    return false if which_color(move_array[0]) != current_player.color
    return false if !empty?(move_array[1]) && which_color(move_array[1]) == current_player.color
    return false unless which_rule(which_piece(move_array[0]),move_array[0],move_array[1])
    return false if path_blocked?(move_array[0],move_array[1])

    true
  end
end
