# frozen_string_literal: true

# Hangman lets you play the game
class Hangman
  def setup_game
    word = random_word
    guesses = []
    player_won = play_game(word, guesses)
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
    puts "Type a valid letter and press enter to make a guess"
    guess = ""
    guess = gets.chomp.downcase until !guesses.include?(guess) && guess =~ /[a-z]/ && guess.length == 1
    guess
  end

  def gussed_word?(word, guesses)
    word.each_char.all? { |char| guesses.include? char }
  end

  def display_winner(player_won)
    puts "Game Over!"
    puts player_won ? "You win!" : "You lose :("
  end

  def play_game(word, guesses)
    mistakes = 8
    puts "Guess the secret word before making #{mistakes} mistakes"
    until mistakes.zero? || gussed_word?(word, guesses)
      new_guess = guess(guesses)
      guesses.push(new_guess)
      display_turn(word, guesses)
      mistakes -= 1 unless word.split("").include? new_guess
      puts "You have #{mistakes} mistakes left"
    end
    mistakes.positive?
  end
end

game = Hangman.new
game.setup_game
