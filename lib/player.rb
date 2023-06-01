# frozen_string_literal: true

# Handling the player characteristics and actions
class Player
  attr_reader :color
  
  def initialize(name, color)
    @name = name
    @color = color
  end
end
