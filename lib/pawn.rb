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
      "\e[1;37m \u265f \e[0m"
    else
      "\e[30m \u265f \e[0m"
    end
  end
end
