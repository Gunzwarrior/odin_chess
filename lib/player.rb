# frozen_string_literal: true

# Handling the player characteristics and actions
class Player
  attr_reader :color
  
  def initialize(name, color)
    @name = name
    @color = color
  end

  def say_move
    gets.chomp
  end

  def valid_move?(move_said)
    # move transformed from string to array
    # check if array length = 5
    # check if [0] & [3] letters a to h
    # check if [1] & [4] numbers 1 to 8
    # not valid if not respected all those criterias
  end

end
