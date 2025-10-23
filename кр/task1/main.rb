class FileBatchEnumerator
  include Enumerable

  def initialize(file_path, batch_size)
    @file_path = file_path
    @batch_size = batch_size.to_i
  end

  def each
    return enum_for(:each) unless block_given?
    File.open(@file_path, "r") do |file|
      batch = []
      file.each_line do |line|
        batch << line.chomp

        if batch.size >= @batch_size
          yield batch
          batch = []
        end
      end

      yield batch unless batch.empty?
    end
  rescue Errno::ENOENT
    warn "Файл за шляхом #{@file_path} не знайдено."
  rescue => e
    warn "Помилка при читанні файлу: #{e.message}"
  end
end

enumerator = FileBatchEnumerator.new('C:/Users/Lenovo/RubymineProjects/laba1/ruby/кр/task1/data', 5)
enumerator.each do |batch|
  p batch
end
puts