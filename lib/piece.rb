# frozen_string_literal: true

# Handles characteristics of all pieces
class Piece
  attr_accessor :never_moved
  attr_reader :color
  
  def initialize(player, never_moved = true)
    @color = player.color
    @never_moved = never_moved
  end
end