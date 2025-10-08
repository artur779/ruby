def cut_cake(cake)
  rows = cake.size
  cols = cake.first.size

    raise "Усі рядки мають бути однакової довжини."unless cake.all? { |row| row.size == cols }

  raisins = []
  cake.each_with_index do |row, i|
    row.chars.each_with_index do |cell, j|
      raisins << [i, j] if cell == 'o'
    end
  end

  n = raisins.size
  raise "Кількість родзинок має бути >1 та <10" unless (2..9).include?(n)

  total_area = rows * cols
  raise "Пиріг не можна поділити рівно!" unless total_area % n == 0

  piece_area = total_area / n
  all_results = []

  search = lambda do |remaining_raisins, used, current_pieces|
    if remaining_raisins.empty?
      all_results << current_pieces.map(&:dup)
      return
    end

    ri, rj = remaining_raisins.first

    (0..ri).each do |top|
      (ri...rows).each do |bottom|
        (0..rj).each do |left|
          (rj...cols).each do |right|
            h = bottom - top + 1
            w = right - left + 1
            next unless h * w == piece_area

            sub = []
            count = 0
            valid = true

            (top..bottom).each do |ii|
              line = ""
              (left..right).each do |jj|
                if used[ii][jj]
                  valid = false
                  break
                end
                line << cake[ii][jj]
                count += 1 if cake[ii][jj] == 'o'
              end
              sub << line
            end

            if valid && count == 1
              new_used = Marshal.load(Marshal.dump(used))
              (top..bottom).each { |ii| (left..right).each { |jj| new_used[ii][jj] = true } }
              search.call(remaining_raisins.drop(1), new_used, current_pieces + [sub])
            end
          end
        end
      end
    end
  end

  used = Array.new(rows) { Array.new(cols, false) }
  search.call(raisins, used, [])

  raise "Розбиття не знайдено" if all_results.empty?

  best = all_results.max_by { |pieces| pieces.first.first.size }
  best
end

cake = [
  ".......",
  "..o....",
  "...o...",
  "......."
]

res = cut_cake(cake)

puts "["
res.each_with_index do |piece, i|
  piece.each { |line| puts "  #{line}" }
  puts "," unless i == res.size - 1
end
puts "]"
