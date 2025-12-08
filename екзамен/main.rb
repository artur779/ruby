class RetryExecutor
  def initialize(retries: 3, delay: 1) #це параметри за замовчуванням,якщо далі не вказати які використовувати
    @retries = retries
    @delay = delay
  end

  def execute
    attempts = 0

    begin
      attempts += 1
      yield
    rescue => e
      puts "Помилка: #{e.message}. Спроба #{attempts}/#{@retries}"
      if attempts < @retries
        sleep @delay
        retry
      end
    end
  end
end

executor = RetryExecutor.new(retries: 3, delay: 2)

executor.execute do
  puts "Запускаю дію"
  raise "Помилка"
end

