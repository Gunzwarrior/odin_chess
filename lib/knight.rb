# frozen_string_literal: true

require_relative 'piece'

# Handles the specifics of the knight piece
class Knight < Piece
  attr_reader :aspect

  def initialize(color)
    super(color)
    @aspect = setup_aspect
  end

  def setup_aspect
    if @color == 'white'
      "\u265e"
    else
      "\u2658"
    end
  end
end