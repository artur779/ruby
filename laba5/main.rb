sum3 = ->(a, b, c) { a + b + c }

def curry3(proc_or_lambda, given_args = [])
  arity = proc_or_lambda.arity

  lambda do |*new_args|
    all_args = given_args + new_args

    if all_args.size > arity
      puts ArgumentError, "забагато аргументів (очікувалося #{arity}, отримано #{all_args.size})"
      return nil
    end

    if all_args.size == arity
      proc_or_lambda.call(*all_args)
    else
      curry3(proc_or_lambda, all_args)
    end
  end
end

cur = curry3(sum3)

puts cur.call(1).call(2).call(3)     # => 6
puts cur.call(1, 2).call(3)          # => 6
puts cur.call(1).call(2, 3)          # => 6
p cur.call()                         # => повертає callable (Proc)
puts cur.call(1, 2, 3)               # => 6
puts cur.call(1, 2, 3, 4)          # => ArgumentError

f = ->(a, b, c) { "#{a}-#{b}-#{c}" }
cF = curry3(f)
puts cF.call('A').call('B', 'C')     #=> "A-B-C"

