#!/usr/bin/env ruby
require 'date'
require 'optparse'

#年月の取得
options = ARGV.getopts('y:', 'm:')
if options["y"].to_s == ""
  year = Date.today.year
elsif options["y"].to_i >= 1970 && options["y"].to_i <= 2100
  year = options["y"].to_i
else
  puts "-yオプションの範囲外です。1970～2100の間で入力してください。"
  exit
end
if options["m"].to_s == ""
  month = Date.today.month
elsif options["m"].to_i >= 1 && options["m"].to_i <= 12
  month = options["m"].to_i
else
  puts "-mオプションの範囲外です。1～12の間で入力してください。"
  exit
end

#取得した年月の初日と末日を取得
first_day = Date.new(year, month, 1)
last_day = Date.new(year, month, -1)

#カレンダー表示
puts "    #{month}月  #{year}"
puts "日 月 火 水 木 金 土"
print "   "*first_day.wday  #初日の曜日からスペース整形
(first_day..last_day).each do |n|
  if n != Date.today
    print n.day.to_s.rjust(2) + " " #数字部分を2桁、後ろに1スペースで整形
  else
    print "\e[31m" + n.day.to_s.rjust(2) + "\e[0m" + " " #上記出力＋色付け
  end
  printf "\n" if n.wday == 6 #土曜日だったら改行
end
