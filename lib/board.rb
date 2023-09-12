require_relative 'message'

# frozen_string_literal: true

# Handling the board characteristics
class Board

  include Message
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
    board[start_array[0]][start_array[1]].never_moved = false if board[start_array[0]][start_array[1]].never_moved == true
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

  def never_moved?(string)
    array = board_array(string)
    board[array[0]][array[1]].never_moved
  end

  def which_rule(piece, start, finish, moved)
    if piece == Rook
      rule_rook(start, finish, moved)
    elsif piece == Bishop
      rule_bishop(start, finish)
    elsif piece == Queen
      rule_queen(start,finish)
    elsif piece == Pawn
      rule_pawn(start,finish, moved)
    elsif piece == King
      rule_king(start, finish, moved)
    elsif piece == Knight
      rule_knight(start, finish)
    end
  end

  def rule_rook(start, finish, moved)
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
    return true if rule_rook(start,finish, true)
    return true if rule_bishop(start,finish)
    
    false
  end

  def rule_pawn(start, finish, moved)
    start_array = board_array(start)
    finish_array = board_array(finish)
    number_forward = board[start_array[0]][start_array[1]].color == "white" ? 1 : -1
    go_forward = start_array[0]-finish_array[0] == number_forward
    first_forward = start_array[0]-finish_array[0] == number_forward * 2
    go_one_step_sideway = (start_array[1]-finish_array[1]).abs == 1
    enemy_present = !empty?(finish) && board[finish_array[0]][finish_array[1]].color != board[start_array[0]][start_array[1]].color
    return true if moved == true && start[0] == finish[0] && first_forward && empty?(finish)
    return true if start[0] == finish[0] && go_forward && empty?(finish)
    return true if go_forward && go_one_step_sideway && enemy_present

    false
  end

  def which_rook_castle(finish)
    if finish == 'g1'
      'h1'
    elsif finish == 'c1'
      'a1'
    elsif finish == 'g8'
      'h8'
    elsif finish == 'c8'
      'a8'
    else
      false
    end
  end

  def which_rook_move_castle(string)
    if string == 'h1'
      'f1'
    elsif string == 'a1'
      'd1'
    elsif string == 'h8'
      'f8'
    elsif string == 'a8'
      'd8'
    else
      false
    end
  end

  def rule_king(start, finish, moved)
    # fix castling (currently king can't jump over rook)
    start_array = board_array(start)
    finish_array = board_array(finish)
    rook_castle = which_rook_castle(finish)
    if rook_castle
      rook_castle_array = board_array(rook_castle)
    end
    if rook_castle_array && board[rook_castle_array[0]][rook_castle_array[1]].class == Rook
      rook_never_moved = board[rook_castle_array[0]][rook_castle_array[1]].never_moved
    end
    go_castle = (start_array[1]-finish_array[1]).abs == 2
    go_one_step = (start_array[1]-finish_array[1]).abs <= 1 && (start_array[0]-finish_array[0]).abs <= 1
    if moved == true && rule_rook(start, finish, moved) && go_castle && rook_never_moved
      move(rook_castle, which_rook_move_castle(rook_castle))
      return true
    end
    return true if rule_rook(start,finish, moved) && go_one_step
    return true if rule_bishop(start,finish) && go_one_step
    
    false
  end

  def rule_knight(start, finish)
    start_array = board_array(start)
    finish_array = board_array(finish)
    l_shape_path = ((start_array[1]-finish_array[1]).abs == 2 && (start_array[0]-finish_array[0]).abs == 1) ||
                   ((start_array[1]-finish_array[1]).abs == 1 && (start_array[0]-finish_array[0]).abs == 2)
    return true if l_shape_path

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
      return false
    end
    !empty_path?(path)
  end

  def diagonal_path?(start, finish)
    (start[0]-finish[0]).abs == (start[1]-finish[1]).abs
  end

  def make_diagonal_path(start, finish)
    path = []
    start_y = start[0]
    start_x = start[1]
    if start[0] < finish[0]
      updown_move = 1
    else
      updown_move = -1
    end
    if start[1] < finish[1]
      leftright_move = 1
    else
      leftright_move = -1
    end
    count = (start[0] - finish[0]).abs
    (count-1).times do
      path.push([start_y+updown_move,start_x+leftright_move])
      start_y+=updown_move
      start_x+=leftright_move
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
      unless board[element[0]][element[1]] == ' '
      puts path_is_blocked
      return false
      end
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
    puts
    puts "   a  b  c  d  e  f  g  h "

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

    puts "   a  b  c  d  e  f  g  h "
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
    puts intro
    loop do
      print player_prompt(current_player.name)
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

  def same_spot(array)
    if array[0] == array[1]
      puts wrong_spot
      return true
    end
    false
  end

  def wrong_color(string)
    if which_color(string) != current_player.color
      puts wrong_piece_color
      return true
    end
    false
  end

  def empty_move(string)
    if empty?(string)
      puts empty_spot
      return true
    end
    false
  end

  def capture_same_color(string)
    if !empty?(string) && which_color(string) == current_player.color
      puts same_color
      return true
    end
    false
  end

  def move_validation(move_said)
    return false unless current_player.valid_move?(move_said)
    move_array = move_said.split(' ')
    return false if empty_move(move_array[0])
    return false if wrong_color(move_array[0])
    return false if same_spot(move_array)
    return false if capture_same_color(move_array[1])
    return false if path_blocked?(move_array[0],move_array[1])
    return false unless which_rule(which_piece(move_array[0]),move_array[0],move_array[1], never_moved?(move_array[0]))

    true
  end
end
