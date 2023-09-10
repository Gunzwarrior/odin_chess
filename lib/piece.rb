# frozen_string_literal: true

# Handles characteristics of all pieces
class Piece
  attr_accessor :never_moved
  attr_reader :color
  
  def initialize(player)
    @color = player.color
    @never_moved = true
  end
end