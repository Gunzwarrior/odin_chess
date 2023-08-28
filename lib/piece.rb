# frozen_string_literal: true

# Handles characteristics of all pieces
class Piece
  attr_reader :color
  
  def initialize(player)
    @color = player.color
  end
end