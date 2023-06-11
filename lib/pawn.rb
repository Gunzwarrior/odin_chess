# frozen_string_literal: true

require_relative 'piece'

# Handles the specifics of the pawn piece
class Pawn < Piece
  attr_reader :aspect

  def initialize(color)
    super(color)
    @aspect = setup_aspect
  end

  def setup_aspect
    if @color == 'white'
      "\u265f"
    else
      "\u2659"
    end
  end
end
