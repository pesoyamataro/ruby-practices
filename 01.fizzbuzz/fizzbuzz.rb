def fizz_buzz(n)
  result = ""
  result = "Fizz" if n % 3 == 0
  result += "Buzz" if n % 5 == 0
  result = n.to_s if result.empty?
  result
end

(1..20).each do |i|
  puts fizz_buzz(i)
end
