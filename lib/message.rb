# frozen_string_literal: true

module Message
  def intro
    'Start of the game'
  end

  def player_prompt(player)
    "Player #{player} > "
  end
end