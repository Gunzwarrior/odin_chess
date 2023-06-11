# frozen_string_literal: true

require_relative 'piece'

# Handles the specifics of the bishop piece
class Bishop < Piece
  attr_reader :aspect

  def initialize(color)
    super(color)
    @aspect = setup_aspect
  end

  def setup_aspect
    if @color == 'white'
      "\u265d"
    else
      "\u2657"
    end
  end
end