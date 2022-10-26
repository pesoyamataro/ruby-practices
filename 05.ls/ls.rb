#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

MAX_COLUMN = 3
SPACE_LENGTH = 3

def main
  files = search_files(ARGV[0])
  output(files)
end

def search_files(path)
  return [path] if FileTest.file?(path.to_s)

  dirpath = ARGV.empty? ? Dir.getwd : path
  files = []
  Dir.foreach(dirpath) do |file|
    files << file unless file.start_with?('.')
  end
  files.sort
end

def output(files_name)
  row_count = (files_name.size.to_f / MAX_COLUMN).ceil
  display_width = adjust_width(files_name).max
  row_count.times do |i|
    MAX_COLUMN.times do |j|
      print ljust_kana(files_name[i + j * row_count], display_width)
      print "\n" if ((j + 1) % MAX_COLUMN).zero?
    end
  end
end

def adjust_width(files_chars)
  addition_count = 2
  files_chars.map do |files_char|
    count_ascii(files_char, addition_count) + SPACE_LENGTH
  end
end

def ljust_kana(file_name, max_width)
  return '' if file_name.nil?

  addition_count = 1
  file_name.ljust(max_width - count_ascii(file_name, addition_count))
end

def count_ascii(str, char_count)
  str.chars.sum { |c| c.ascii_only? ? char_count - 1 : char_count }
end

main
