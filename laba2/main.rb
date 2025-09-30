def cut_cake(cake)
  rows = cake.size
  cols = cake.first.size
  raisins = []

  # Збираємо координати родзинок
  cake.each_with_index do |row, i|
    row.chars.each_with_index do |cell, j|
      raisins << [i, j] if cell == 'o'
    end
  end

  n = raisins.size
  total_area = rows * cols
  piece_area = total_area / n

  raise "Пиріг не можна поділити рівно!" unless total_area % n == 0

  result = []
  used = Array.new(rows) { Array.new(cols, false) }

  raisins.each do |(ri, rj)|
    found = false

    (0..ri).each do |top|
      (ri...rows).each do |bottom|
        (0..rj).each do |left|
          (rj...cols).each do |right|
            h = bottom - top + 1
            w = right - left + 1

            if h * w == piece_area
              sub = []
              count = 0
              valid = true

              (top..bottom).each do |ii|
                line = ""
                (left..right).each do |jj|
                  valid = false if used[ii][jj]
                  line << cake[ii][jj]
                  count += 1 if cake[ii][jj] == 'o'
                end
                sub << line
              end

              if valid && count == 1
                (top..bottom).each { |ii| (left..right).each { |jj| used[ii][jj] = true } }
                result << sub
                found = true
                break
              end
            end
          end
          break if found
        end
        break if found
      end
      break if found
    end
  end

  result
end

# ====== Приклад використання ======
cake = [
  ".......",
  "..o....",
  "...o....",
  "........"
]

res = cut_cake(cake)

puts "["
res.each_with_index do |piece, i|
  piece.each { |line| puts "  #{line}" }
  puts "," unless i == res.size - 1
end
puts "]"
