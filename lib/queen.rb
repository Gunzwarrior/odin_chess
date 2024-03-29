# frozen_string_literal: true

require_relative 'piece'

# Handles the specifics of the queen piece
class Queen < Piece
  attr_reader :aspect

  def initialize(color, never_moved = true)
    super(color)
    @never_moved = never_moved
    @aspect = setup_aspect
  end

  def setup_aspect
    if @color == 'white'
      "\e[1;37m \u265b \e[0m"
    else
      "\e[30m \u265b \e[0m"
    end
  end
end
