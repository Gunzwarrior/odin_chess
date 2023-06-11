# frozen_string_literal: true

require_relative 'piece'

# Handles the specifics of the king piece
class King < Piece
  attr_reader :aspect

  def initialize(color)
    super(color)
    @aspect = setup_aspect
  end

  def setup_aspect
    if @color == 'white'
      "\u265a"
    else
      "\u2654"
    end
  end
end