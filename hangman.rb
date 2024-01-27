# frozen_string_literal: true

require "json"

# Hangman lets you play the game
class Hangman
  def setup_game
    data = load_game if game_type == "l"
    word = data ? data[:word] : random_word
    guesses = data ? data[:guesses] : []
    display_turn(word, guesses)
    player_won = play_game(word, guesses, data ? data[:mistakes] : 8)
    return if player_won.nil?

    puts "The secret word was: #{word}" unless player_won
    display_winner(player_won)
  end

  private

  def random_word
    lines = File.readlines("words.txt")
    word = ""
    word = lines[rand(lines.length)].chomp until word.length.between?(5, 12)
    word
  end

  def display_turn(word, guesses)
    print "Word: "
    word.each_char { |char| print "#{guesses.include?(char) ? char : '_'} " }
    puts "\nIncorrect letters: #{(guesses - word.split('')).join('')}"
  end

  def guess(guesses)
    puts "Type a valid letter and press enter to make a guess. Enter 'save' to save the game."
    guess = ""
    guess = gets.chomp.downcase until
      (!guesses.include?(guess) && guess =~ /[a-z]/ && guess.length == 1) || guess == "save"
    guess
  end

  def gussed_word?(word, guesses)
    word.each_char.all? { |char| guesses.include? char }
  end

  def display_winner(player_won)
    puts "Game Over!"
    puts player_won ? "You win!" : "You lose :("
  end

  def play_game(word, guesses, mistakes = 8)
    puts "Guess the secret word before making #{mistakes} mistakes"
    until mistakes.zero? || gussed_word?(word, guesses)
      new_guess = guess(guesses)
      return save_game(word, guesses, mistakes) if new_guess == "save"

      guesses.push(new_guess)
      display_turn(word, guesses)
      mistakes -= 1 unless word.split("").include? new_guess
      puts "You have #{mistakes} mistakes left"
    end
    mistakes.positive?
  end

  def save_game(word, guesses, mistakes)
    path = path_name
    confirm = File.exist?(path) ? confirm_overwrite : true
    return save_game(word, guesses, mistakes) unless confirm

    Dir.mkdir "saves" unless Dir.exist? "saves"
    save_data = JSON.dump({ word: word, guesses: guesses, mistakes: mistakes })
    File.open(path, "w") { |file| file.write save_data }
    puts "The game was saved"
  end

  def confirm_overwrite
    puts "That file already exists. Do you want to overwrite it?"
    confirmation = gets.chomp.downcase
    %w[y yes].include? confirmation
  end

  def game_type
    puts "Enter 'l' to load a saved game or 'n' to start a new game."
    choice = gets.chomp.downcase until %w[l n].include? choice
    choice
  end

  def path_name
    puts "Enter a file name containing only letters and numbers"
    filename = gets.chomp until filename =~ /^[A-Za-z0-9]+$/
    "./saves/#{filename}.json"
  end

  def load_game
    path = path_name
    until File.exist? path
      puts "File doesn't exist in your saves."
      path = path_name
    end
    begin
      saved_data = File.read path
      JSON.parse(saved_data, { symbolize_names: true })
    rescue StandardError
      puts "Unable to load saved file. Starting new game..."
    end
  end
end

game = Hangman.new
game.setup_game
