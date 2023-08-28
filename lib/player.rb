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
    move_array = move_said.split("")
    letter_array = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
    number_array = ['1', '2', '3', '4', '5', '6', '7', '8']
    return false unless move_array.length == 5
    return false unless letter_array.include?(move_array[0]) && letter_array.include?(move_array[3]) 
    return false unless number_array.include?(move_array[1]) && number_array.include?(move_array[4]) 

    true
  end

end
