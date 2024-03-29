# frozen_string_literal: true

require_relative 'message'
require 'json'

# Handling the board characteristics
class Board
  include Message
  attr_reader :board, :player2, :player1, :current_player, :en_passant_target, :black_pieces_lost,
              :white_pieces_lost, :black_positions, :white_positions, :king_check

  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    @board = setup_board
    @current_player = player1
    @en_passant_target = nil
    @black_pieces_lost = []
    @white_pieces_lost = []
    @white_positions = setup_positions(player1)
    @black_positions = setup_positions(player2)
    @king_check = false
  end

  def empty_board
    array = []
    8.times { array.push([]) }
    array.each do |arr|
      8.times { arr.push(' ') }
    end
  end

  def move(start, finish, real)
    start_array = board_array(start)
    finish_array = board_array(finish)
    if real && board[finish_array[0]][finish_array[1]] != ' '
      if board[finish_array[0]][finish_array[1]].color == 'white'
        @white_pieces_lost.push(board[finish_array[0]][finish_array[1]].aspect)
      else
        @black_pieces_lost.push(board[finish_array[0]][finish_array[1]].aspect)
      end
    end
    if board[start_array[0]][start_array[1]].never_moved == true && real
      board[start_array[0]][start_array[1]].never_moved = false
    end
    board[finish_array[0]][finish_array[1]] = board[start_array[0]][start_array[1]]
    board[start_array[0]][start_array[1]] = ' '
    print player_prompt(current_player.name) if current_player.name == 'Computer' && real
    puts "#{start} #{finish}" if current_player.name == 'Computer' && real
    pretty_board if real
  end

  def board_array(string)
    array = string.split('')
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
      rule_queen(start, finish)
    elsif piece == Pawn
      rule_pawn(start, finish, moved)
    elsif piece == King
      rule_king(start, finish, moved)
    elsif piece == Knight
      rule_knight(start, finish)
    end
  end

  def rule_rook(start, finish, _moved)
    return true if start[0] == finish[0] || start[1] == finish[1]

    false
  end

  def rule_bishop(start, finish)
    start_array = board_array(start)
    finish_array = board_array(finish)
    return true if diagonal_path?(start_array, finish_array)

    false
  end

  def rule_queen(start, finish)
    return true if rule_rook(start, finish, true)
    return true if rule_bishop(start, finish)

    false
  end

  def rule_pawn(start, finish, moved)
    start_array = board_array(start)
    finish_array = board_array(finish)
    number_forward = board[start_array[0]][start_array[1]].color == 'white' ? 1 : -1
    go_forward = start_array[0] - finish_array[0] == number_forward
    first_forward = start_array[0] - finish_array[0] == number_forward * 2
    first_move_forward = moved == true && start[0] == finish[0] && first_forward && empty?(finish)
    go_one_step_sideway = (start_array[1] - finish_array[1]).abs == 1
    enemy_present = !empty?(finish) && board[finish_array[0]][finish_array[1]].color != board[start_array[0]][start_array[1]].color
    en_passant_move = go_forward && go_one_step_sideway && empty?(finish)
    en_passant_pawn = [start_array[0], finish_array[1]]
    if first_move_forward
      @en_passant_target = [finish_array[0], finish_array[1]]
      return true
    end
    return true if start[0] == finish[0] && go_forward && empty?(finish)
    return true if go_forward && go_one_step_sideway && enemy_present

    if en_passant_move && en_passant_pawn == @en_passant_target
      if board[(finish_array[0] + number_forward)][finish_array[1]].respond_to?(:color) && board[(finish_array[0] + number_forward)][finish_array[1]].color == 'white'
        @white_pieces_lost.push(board[(finish_array[0] + number_forward)][finish_array[1]].aspect)
      else
        @black_pieces_lost.push(board[(finish_array[0] + number_forward)][finish_array[1]].aspect)
      end
      board[(finish_array[0] + number_forward)][finish_array[1]] = ' '
      en_passant_y = (finish.split('')[1].to_i - number_forward).to_s
      en_passant_position_array = [finish.split('')[0], en_passant_y]
      en_passant_position = en_passant_position_array.join('')
      if current_player == player1
        unless find_position(
          black_positions, en_passant_position
        ).nil?
          black_positions.delete(black_positions[find_position(black_positions,
                                                               en_passant_position)])
        end
      else
        unless find_position(
          white_positions, en_passant_position
        ).nil?
          white_positions.delete(white_positions[find_position(white_positions,
                                                               en_passant_position)])
        end
      end
      return true
    end
    false
  end

  def which_rook_castle(finish)
    case finish
    when 'g1'
      'h1'
    when 'c1'
      'a1'
    when 'g8'
      'h8'
    when 'c8'
      'a8'
    else
      false
    end
  end

  def which_rook_move_castle(string)
    case string
    when 'h1'
      'f1'
    when 'a1'
      'd1'
    when 'h8'
      'f8'
    when 'a8'
      'd8'
    else
      false
    end
  end

  def king_castle_path(finish)
    case finish
    when 'g1'
      %w[e1 f1 g1]
    when 'c1'
      %w[e1 d1 c1]
    when 'g8'
      %w[e8 f8 g8]
    when 'c8'
      %w[e8 d8 c8]
    else
      false
    end
  end

  def castling_through_check?(finish)
    array = king_castle_path(finish)
    array.each do |element|
      return true if vulnerable_square?(element)
    end
    false
  end

  def rule_king(start, finish, moved)
    start_array = board_array(start)
    finish_array = board_array(finish)
    rook_castle = which_rook_castle(finish)
    rook_castle_array = board_array(rook_castle) if rook_castle
    if rook_castle_array && board[rook_castle_array[0]][rook_castle_array[1]].instance_of?(Rook)
      rook_never_moved = board[rook_castle_array[0]][rook_castle_array[1]].never_moved
    end
    go_castle = (start_array[1] - finish_array[1]).abs == 2
    go_one_step = (start_array[1] - finish_array[1]).abs <= 1 && (start_array[0] - finish_array[0]).abs <= 1
    if moved == true && rule_rook(start, finish,
                                  moved) && go_castle && rook_never_moved && !castling_through_check?(finish)
      move(rook_castle, which_rook_move_castle(rook_castle), false)
      update_pieces("#{rook_castle} #{which_rook_move_castle(rook_castle)}")
      return true
    end
    return true if rule_rook(start, finish, moved) && go_one_step
    return true if rule_bishop(start, finish) && go_one_step

    false
  end

  def rule_knight(start, finish)
    start_array = board_array(start)
    finish_array = board_array(finish)
    l_shape_path = ((start_array[1] - finish_array[1]).abs == 2 && (start_array[0] - finish_array[0]).abs == 1) ||
                   ((start_array[1] - finish_array[1]).abs == 1 && (start_array[0] - finish_array[0]).abs == 2)
    return true if l_shape_path

    false
  end

  def path_blocked?(start, finish, move)
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
    !empty_path?(path, move)
  end

  def diagonal_path?(start, finish)
    (start[0] - finish[0]).abs == (start[1] - finish[1]).abs
  end

  def make_diagonal_path(start, finish)
    path = []
    start_y = start[0]
    start_x = start[1]
    updown_move = if start[0] < finish[0]
                    1
                  else
                    -1
                  end
    leftright_move = if start[1] < finish[1]
                       1
                     else
                       -1
                     end
    count = (start[0] - finish[0]).abs
    (count - 1).times do
      path.push([start_y + updown_move, start_x + leftright_move])
      start_y += updown_move
      start_x += leftright_move
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
    (begin_number...end_number - 1).each do
      path.push([start[0], begin_number + 1])
      begin_number += 1
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
    (begin_number...end_number - 1).each do
      path.push([begin_number + 1, start[1]])
      begin_number += 1
    end
    path
  end

  def empty_path?(path, move)
    return true if path.length.zero?

    path.each do |element|
      unless board[element[0]][element[1]] == ' '
        puts path_is_blocked if move && current_player.name != 'Computer'
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
    number_array = %w[8 7 6 5 4 3 2 1]
    number = 0
    puts
    puts '   a  b  c  d  e  f  g  h '

    @board.each do |arr|
      print "#{number_array[number]} "
      arr.each do |element|
        background_color = black_first == true ? 44 : 46
        if defined?(element.aspect)
          print "\e[#{background_color}m#{element.aspect}\e[0m"
        else
          print "\e[#{background_color};30m#{" #{element} "}\e[0m"
        end
        black_first = black_first != true
      end
      black_first = black_first != true
      print " #{number_array[number]}"
      number += 1
      puts
    end

    puts '   a  b  c  d  e  f  g  h '
    puts
  end

  def setup_board
    array = empty_board
    array[0] = [Rook.new(player2.color),
                Knight.new(player2.color),
                Bishop.new(player2.color),
                Queen.new(player2.color),
                King.new(player2.color),
                Bishop.new(player2.color),
                Knight.new(player2.color),
                Rook.new(player2.color)]
    array[1] = []
    8.times { array[1].push(Pawn.new(player2.color)) }
    array[7] = [Rook.new(player1.color),
                Knight.new(player1.color),
                Bishop.new(player1.color),
                Queen.new(player1.color),
                King.new(player1.color),
                Bishop.new(player1.color),
                Knight.new(player1.color),
                Rook.new(player1.color)]
    array[6] = []
    8.times { array[6].push(Pawn.new(player1.color)) }
    array
  end

  def setup_positions(player)
    white_array = %w[a2 b2 c2 d2 e2 f2 g2 h2
                     a1 b1 c1 d1 e1 f1 g1 h1]
    black_array = %w[a8 b8 c8 d8 e8 f8 g8 h8
                     a7 b7 c7 d7 e7 f7 g7 h7]

    array = if player == player1
              white_array
            else
              black_array
            end
    array.map do |element|
      piece = board_array(element)
      [board[piece[0]][piece[1]], element]
    end
  end

  def promotion(move_said)
    move_array = move_said.split(' ')
    promotion_spot = board_array(move_array[1])
    first_prompt = true
    position = current_player == player1 ? white_positions : black_positions
    position_index = find_position(position, move_array[0])
    if current_player.name == 'Computer'
      %w[queen bishop rook knight].sample
    else
      loop do
        if first_prompt
          print promotion_prompt(current_player.name)
        else
          print player_prompt(current_player.name)
        end
        choice = gets.chomp
        case choice.downcase
        when 'queen'
          board[promotion_spot[0]][promotion_spot[1]] = Queen.new(current_player.color)
          position[position_index][0] = board[promotion_spot[0]][promotion_spot[1]]
          break
        when 'bishop'
          board[promotion_spot[0]][promotion_spot[1]] = Bishop.new(current_player.color)
          position[position_index][0] = board[promotion_spot[0]][promotion_spot[1]]
          break
        when 'rook'
          board[promotion_spot[0]][promotion_spot[1]] = Rook.new(current_player.color)
          position[position_index][0] = board[promotion_spot[0]][promotion_spot[1]]
          break
        when 'knight'
          board[promotion_spot[0]][promotion_spot[1]] = Knight.new(current_player.color)
          position[position_index][0] = board[promotion_spot[0]][promotion_spot[1]]
          break
        else
          first_prompt = false
          puts wrong_promotion
        end
      end
    end
    pretty_board
  end

  def pawn_promotable(move_said)
    row = move_said[-1]
    end_row = current_player.color == 'white' ? '8' : '1'
    return false unless row == end_row

    move_array = move_said.split(' ')
    return false if which_piece(move_array[1]) != Pawn

    true
  end

  def display_pieces_lost
    puts black_cemetary(black_pieces_lost) if black_pieces_lost != []
    puts white_cemetary(white_pieces_lost) if white_pieces_lost != []
    puts if white_pieces_lost != [] || black_pieces_lost != []
  end

  def find_position(array, string)
    array.index { |element| element[1] == string }
  end

  def find_king_position
    if current_player == player1
      index = white_positions.index { |element| element[0].instance_of?(King) }
      white_positions[index][1]
    else
      index = black_positions.index { |element| element[0].instance_of?(King) }
      black_positions[index][1]
    end
  end

  def update_pieces(move_said)
    start = move_said.split(' ')[0]
    finish = move_said.split(' ')[1]
    if current_player == player1
      white_positions[find_position(white_positions, start)][1] = finish
      black_positions.delete(black_positions[find_position(black_positions, finish)]) unless find_position(
        black_positions, finish
      ).nil?
    else
      black_positions[find_position(black_positions, start)][1] = finish
      white_positions.delete(white_positions[find_position(white_positions, finish)]) unless find_position(
        white_positions, finish
      ).nil?
    end
  end

  def save_game
    serialized_state = serialize_state
    Dir.mkdir('saved_game') unless Dir.exist?('saved_game')
    save_file = 'saved_game/save.txt'
    File.open(save_file, 'w') do |file|
      file.puts(serialized_state)
    end
  end

  def load_game
    save_file = 'saved_game/save.txt'
    saved_hash = JSON.parse(File.read(save_file))
    @board = load_board(saved_hash['board'])
    @current_player = current_player_from_json(saved_hash['current_player'])
    @en_passant_target = saved_hash['en_passant_target']
    @black_pieces_lost = saved_hash['black_pieces_lost']
    @white_pieces_lost = saved_hash['white_pieces_lost']
    @black_positions = load_position(saved_hash['black_positions'])
    @white_positions = load_position(saved_hash['white_positions'])
    @king_check = saved_hash['king_check']
  end

  def load_position(array)
    array.map do |element|
      temp_array = board_array(element[1])
      [@board[temp_array[0]][temp_array[1]], element[1]]
    end
  end

  def load_board(array)
    array.map do |subarray|
      subarray.map do |element|
        case element[0]
        when ' '
          ' '
        when 'knight'
          Knight.new(element[1]['color'], element[1]['never_moved'])
        when 'rook'
          Rook.new(element[1]['color'], element[1]['never_moved'])
        when 'king'
          King.new(element[1]['color'], element[1]['never_moved'])
        when 'queen'
          Queen.new(element[1]['color'], element[1]['never_moved'])
        when 'pawn'
          Pawn.new(element[1]['color'], element[1]['never_moved'])
        when 'bishop'
          Bishop.new(element[1]['color'], element[1]['never_moved'])
        end
      end
    end
  end

  def current_player_from_json(name)
    name == 'One' ? player1 : player2
  end

  def serialize_state
    saved_data_hash = {
      board: serialize_board,
      current_player: current_player.name,
      en_passant_target: en_passant_target,
      black_pieces_lost: black_pieces_lost,
      white_pieces_lost: white_pieces_lost,
      black_positions: black_positions,
      white_positions: white_positions,
      king_check: king_check
    }
    JSON.dump(saved_data_hash)
  end

  def serialize_piece(piece)
    if piece.instance_of?(Rook)
      type = 'rook'
    elsif piece.instance_of?(Bishop)
      type = 'bishop'
    elsif piece.instance_of?(Queen)
      type = 'queen'
    elsif piece.instance_of?(Pawn)
      type = 'pawn'
    elsif piece.instance_of?(King)
      type = 'king'
    elsif piece.instance_of?(Knight)
      type = 'knight'
    end
    hash = { color: piece.color,
             never_moved: piece.never_moved }
    [type, hash]
  end

  def serialize_board
    @board.map do |element|
      element.map do |sub_element|
        if sub_element == ' '
          ' '
        else
          serialize_piece(sub_element)
        end
      end
    end
  end

  def choose_game_mode
    loop do
      puts new_or_load
      move_said = current_player.say_move
      case move_said
      when '1'
        pretty_board
        game_loop
        break
      when '2'
        load_game
        pretty_board
        display_pieces_lost
        game_loop
        break
      end
    end
  end

  def launch_game
    save_file = 'saved_game/save.txt'
    if File.exist?(save_file)
      choose_game_mode
    else
      pretty_board
      game_loop
    end
  end

  def game_loop
    puts intro
    loop do
      print player_prompt(current_player.name) unless current_player.name == 'Computer'
      move_said = if current_player.name == 'Computer'
                    random_move(checkmate_array(current_player.color))
                  else
                    current_player.say_move
                  end
      break if move_said == 'exit'

      if move_said == 'save'
        save_game
        break
      end
      next unless move_validation(move_said)

      move(move_said.split(' ')[0], move_said.split(' ')[1], true)
      @en_passant_target = nil if en_passant_target.nil? && en_passant_target == ' '
      if !@en_passant_target.nil? && board[@en_passant_target[0]][@en_passant_target[1]].respond_to?(:color) && (current_player.color != board[@en_passant_target[0]][@en_passant_target[1]].color)
        @en_passant_target = nil
      end
      promotion(move_said) if pawn_promotable(move_said)
      update_pieces(move_said)
      display_pieces_lost
      player_swap
      if vulnerable_square?(find_king_position)
        puts check(current_player.color)
        puts
        @king_check = true
        if checkmate?(current_player.color)
          puts checkmate(current_player.color)
          break
        end
      else
        @king_check = false
        if checkmate?(current_player.color)
          puts stalemate
          break
        end
      end
    end
  end

  def random_move(position_array)
    random_index = rand(position_array.length)
    random_piece = position_array[random_index][0]
    random_second_index = rand(position_array[random_index][1].length)
    random_move = position_array[random_index][1][random_second_index]
    "#{random_piece} #{random_move}"
  end

  def board_to_coordinates(array)
    x_hash = { a: 0, b: 1, c: 2, d: 3,
               e: 4, f: 5, g: 6, h: 7 }
    y_array = [0, 7, 6, 5, 4, 3, 2, 1, 0]
    letter = x_hash.key(array[1]).to_s
    number = if (array[0]).zero?
               '8'
             else
               y_array.index(array[0]).to_s
             end
    letter + number
  end

  def possible_pawn_move(piece, start)
    start_array = board_array(start)
    result = []
    number_forward = piece.color == 'white' ? 1 : -1
    forward1 = start_array[0] - number_forward
    forward2 = forward1 - number_forward
    sideway_left = start_array[1] - 1
    sideway_right = start_array[1] + 1
    result.push(board_to_coordinates([forward1, start_array[1]])) if forward1 >= 0 && forward1 <= 7
    result.push(board_to_coordinates([forward2, start_array[1]])) if forward2 >= 0 && forward2 <= 7
    if forward1 >= 0 && forward1 <= 7 && sideway_left >= 0 && sideway_left <= 7
      result.push(board_to_coordinates([forward1,
                                        sideway_left]))
    end
    if forward1 >= 0 && forward1 <= 7 && sideway_right >= 0 && sideway_right <= 7
      result.push(board_to_coordinates([forward1,
                                        sideway_right]))
    end

    result
  end

  def possible_rook_move(start)
    start_array = start.split('')
    letter_array = %w[a b c d e f g h]
    number_array = %w[1 2 3 4 5 6 7 8]
    x_moves = []
    y_moves = []
    letter_array.each { |letter| x_moves.push(letter + start_array[1]) }
    number_array.each { |number| y_moves.push(start_array[0] + number) }
    result = x_moves + y_moves
    result.delete(start)
    result
  end

  def possible_king_move(start)
    start_array = board_array(start)
    y_possible = [start_array[0], start_array[0] - 1, start_array[0] + 1]
    x_possible = [start_array[1], start_array[1] - 1, start_array[1] + 1]
    possible = []
    y_possible.each do |x|
      x_possible.each do |y|
        possible.push([x, y])
      end
    end
    result = possible.map { |element| board_to_coordinates(element) }
    result.delete(start)
    end_result = []
    result.each { |element| end_result.push(element) if element.length == 2 }
    end_result
  end

  def possible_knight_move(start)
    start_array = board_array(start)
    possible = [[start_array[0] + 1, start_array[1] + 2], [start_array[0] + 1, start_array[1] - 2],
                [start_array[0] - 1, start_array[1] + 2], [start_array[0] - 1, start_array[1] - 2],
                [start_array[0] + 2, start_array[1] + 1], [start_array[0] + 2, start_array[1] - 1],
                [start_array[0] - 2, start_array[1] + 1], [start_array[0] - 2, start_array[1] - 1]]
    result = possible.map { |element| board_to_coordinates(element) }
    end_result = []
    result.each { |element| end_result.push(element) if element.length == 2 }
    end_result
  end

  def possible_bishop_move(start)
    start_array = board_array(start)
    result = []
    start_y = start_array[0]
    start_x = start_array[1]
    y_temp = start_y
    x_temp = start_x
    while y_temp < 7 && x_temp < 7
      y_temp += 1
      x_temp += 1
      result.push([y_temp, x_temp])
    end
    y_temp = start_y
    x_temp = start_x
    while y_temp.positive? && x_temp.positive?
      y_temp -= 1
      x_temp -= 1
      result.push([y_temp, x_temp])
    end
    y_temp = start_y
    x_temp = start_x
    while y_temp < 7 && x_temp.positive?
      y_temp += 1
      x_temp -= 1
      result.push([y_temp, x_temp])
    end
    y_temp = start_y
    x_temp = start_x
    while y_temp.positive? && x_temp < 7
      y_temp -= 1
      x_temp += 1
      result.push([y_temp, x_temp])
    end
    result.map { |element| board_to_coordinates(element) }
  end

  def possible_queen_move(start)
    possible_rook_move(start) + possible_bishop_move(start)
  end

  def checkmate_rule_selector(piece, coordinates)
    if piece.instance_of?(Pawn)
      possible_pawn_move(piece, coordinates)
    elsif piece.instance_of?(Rook)
      possible_rook_move(coordinates)
    elsif piece.instance_of?(King)
      possible_king_move(coordinates)
    elsif piece.instance_of?(Knight)
      possible_knight_move(coordinates)
    elsif piece.instance_of?(Bishop)
      possible_bishop_move(coordinates)
    elsif piece.instance_of?(Queen)
      possible_queen_move(coordinates)
    end
  end

  def checkmate_array(color)
    result = []
    base_array = color == 'white' ? white_positions : black_positions
    base_array.each do |element|
      result.push([element[1], checkmate_rule_selector(element[0], element[1])])
    end
    result
  end

  def checkmate?(color)
    array = checkmate_array(color)
    array.each do |element|
      element[1].each do |elem|
        return false if check_move_validation([element[0], elem], false) && !still_check([element[0], elem])
      end
    end
    true
  end

  def player_swap
    @current_player = @current_player == player1 ? player2 : player1
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

  def capture_same_color(string, check_test)
    if !empty?(string) && which_color(string) == current_player.color
      puts same_color if current_player.name != 'Computer' && check_test
      return true
    end
    false
  end

  def vulnerable_square?(square)
    array = @current_player.color == 'white' ? black_positions : white_positions
    array.each do |element|
      next if !element[0].instance_of?(Knight) && path_blocked?(element[1], square, false)
      next unless which_rule(element[0].class, element[1], square, never_moved?(element[1]))

      return true
    end
    false
  end

  def still_check(array)
    temp_board = Marshal.load(Marshal.dump(board))
    temp_white_positions = Marshal.load(Marshal.dump(white_positions))
    temp_black_positions = Marshal.load(Marshal.dump(black_positions))
    move(array[0], array[1], false)
    update_pieces(array.join(' '))
    result = vulnerable_square?(find_king_position)
    @board = temp_board
    @white_positions = temp_white_positions
    @black_positions = temp_black_positions
    result
  end

  def check_move_validation(move_array, check_test)
    return false if capture_same_color(move_array[1], check_test)

    return false if which_piece(move_array[0]) != Knight && path_blocked?(move_array[0], move_array[1], false)
    unless which_rule(which_piece(move_array[0]), move_array[0], move_array[1], never_moved?(move_array[0]))
      return false
    end

    true
  end

  def move_validation(move_said)
    return false unless current_player.valid_move?(move_said)

    move_array = move_said.split(' ')
    return false if empty_move(move_array[0])
    return false if wrong_color(move_array[0])
    return false if same_spot(move_array)
    return false if capture_same_color(move_array[1], true)

    return false if which_piece(move_array[0]) != Knight && path_blocked?(move_array[0], move_array[1], true)

    unless which_rule(which_piece(move_array[0]), move_array[0], move_array[1], never_moved?(move_array[0]))
      puts wrong_piece_move(which_piece(move_array[0])) unless current_player.name == 'Computer'
      return false
    end
    if still_check(move_array)
      if king_check
        puts wrong_check unless current_player.name == 'Computer'
      else
        puts cannot_check unless current_player.name == 'Computer'
      end
      return false
    end
    true
  end
end
