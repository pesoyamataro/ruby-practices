def fizz_buzz(n)
  result = ""
  result = "Fizz" if n % 3 == 0
  result += "Buzz" if n % 5 == 0
  result = n if result.empty?
  result.to_s
end

(1..20).each do |i|
  puts fizz_buzz(i)
end
