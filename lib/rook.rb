# frozen_string_literal: true

require_relative 'piece'

# Handles the specifics of the rook piece
class Rook < Piece
  attr_reader :aspect

  def initialize(color)
    super(color)
    @aspect = setup_aspect
  end

  def setup_aspect
    if @color == 'white'
      "\u265c"
    else
      "\u2656"
    end
  end
end