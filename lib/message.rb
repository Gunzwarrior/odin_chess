# frozen_string_literal: true

module Message
  def intro
    <<~START
    Start of the game

    START
  end

  def player_prompt(player)
    "Player #{player} > "
  end

  def wrong_text
    'Please enter a move using coordinates (ex : a2 a3)'
  end

  def wrong_spot
    "You can't stay on the same spot"
  end

  def wrong_piece_color
    "You can't move your opponent's piece"
  end

  def empty_spot
    "This square is empty"
  end

  def same_color
    "You can't capture your own piece"
  end

  def path_is_blocked
    "Your path is blocked"
  end

  def wrong_piece_move(piece)
    "Incorrect #{piece} move"
  end

  def promotion_prompt(player)
    "Pawn promotion for Player #{player} > "
  end

  def black_cemetary(array)
    shape_array = array.map { |piece| piece.aspect.gsub(/[[:space:]]+/, "")}
    print "  "
    shape_array.join("")
  end

  def white_cemetary(array)
    shape_array = array.map { |piece| piece.aspect.gsub(/[[:space:]]+/, "")}
    print "  "
    shape_array.join("")
  end

  def wrong_promotion
    "Please enter Queen, Rook, Bishop or Knight for your promotion"
  end

  def check(color)
    "#{color.capitalize} King in check"
  end

  def wrong_check
    "Incorrect move, King still in check"
  end

  def cannot_check
    "Incorrect move, puts own King in check"
  end

end