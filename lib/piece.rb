# frozen_string_literal: true

# Handles characteristics of all pieces
class Piece
  attr_accessor :never_moved
  attr_reader :color
  
  def initialize(color)
    @color = color
  end
end