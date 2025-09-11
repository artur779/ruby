def play_game
  number = rand(1..100)
  attempts = 0

  puts "Я загадав число від 1 до 100. Спробуй вгадати!"

  loop do
    print "Твоє припущення: "
    guess = gets.to_i
    attempts += 1

    if guess < number
      puts "Більше"
    elsif guess > number
      puts "Менше"
    else
      puts "Вгадано! Кількість спроб: #{attempts}"
      break
    end
  end
end

play_game

