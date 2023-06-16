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
      "\e[1;37m \u265d \e[0m"
    else
      "\e[30m \u265d \e[0m"
    end
  end
end