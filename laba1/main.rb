def word_stats(text)
  words = text.split
  total_words = words.size
  longest_word = words.max_by(&:length)
  unique_words = words.map(&:downcase).uniq
  unique_count = unique_words.size

  print "#{total_words} слів, найдовше: #{longest_word}, унікальних: #{unique_count}"
end

print "Введіть текст: "
text = gets.chomp
word_stats(text)

