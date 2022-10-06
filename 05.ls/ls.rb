#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

max_column = 3
space_length = 3
items = []

# ターゲットの取得
def all_files(items)
  if ARGV.empty? # 引数なしならカレントディレクトリを取得
    dirpath = Dir.getwd
  elsif Dir.exist?(ARGV[0]) # 引数がディレクトリパスとして認識されるならそのまま取得
    dirpath = ARGV[0]
  elsif FileTest.exist?(ARGV[0]) # 引数がファイルとして認識ならそのまま取得
    items << ARGV[0]
  else
    puts "lsrb: '#{ARGV[0]}' にアクセスできません：そのようなファイルやディレクトリはありません"
    exit
  end

  # ディレクトリ指定であれば配列に変換&隠しファイル除去
  if items.empty?
    Dir.foreach(dirpath) do |item|
      items << item unless /^\./.match?(item)
    end
  end
  items.sort
end

# 出力
def output(row, max_column, items, file_width)
  row.times do |m|
    max_column.times do |n|
      print ljust_kana(items[m + n * row], file_width) unless items[m + n * row].nil?
      print "\n" if ((n + 1) % max_column).zero?
    end
  end
end

# ファイル文字数＋全角（アスキーコードではない）文字の場合は1文字分追加
def length_chk(items)
  items.map do |x|
    x.length + x.chars.count { |num| !num.ascii_only? }
  end
end

# 全角の文字数分が右にずれてしまうので全角文字数分マイナスして左詰め
def ljust_kana(str, file_width)
  str.ljust(file_width - str.chars.count { |num| !num.ascii_only? })
end

# options = ARGV.getopts('arl') # 以降の課題用にオプション枠だけ作成。使っていないとrubocopにしょっぴかれるので使うまでコメントアウト
items = all_files(items) # 指定パス（引数なしならカレントディレクトリ）配下の情報を取得
row = (items.size.to_f / max_column).ceil # 表示する行数を取得
file_width = length_chk(items).max + space_length # 表示文字数の最大値取得+表示用スペース追加
output(row, max_column, items, file_width) # 出力
