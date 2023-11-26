# frozen_string_literal: true

require_relative 'message'

# Handling the player characteristics and actions
class Player
  attr_reader :color, :name

  include Message

  def initialize(name, color)
    @name = name
    @color = color
  end

  def say_move
    gets.chomp
  end

  def valid_move?(move_said)
    move_array = move_said.split('')
    letter_array = %w[a b c d e f g h]
    number_array = %w[1 2 3 4 5 6 7 8]
    five_long = move_array.length == 5
    bad_letter = letter_array.include?(move_array[0]) && letter_array.include?(move_array[3])
    bad_number = number_array.include?(move_array[1]) && number_array.include?(move_array[4])
    if !five_long || !bad_letter || !bad_number
      puts wrong_text
      return false
    end

    true
  end
end
