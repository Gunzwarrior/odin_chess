# frozen_string_literal: true

require_relative 'piece'

# Handles the specifics of the queen piece
class Queen < Piece
  attr_reader :aspect

  def initialize(color)
    super(color)
    @aspect = setup_aspect
  end

  def setup_aspect
    if @color == 'white'
      "\u265b"
    else
      "\u2655"
    end
  end
end