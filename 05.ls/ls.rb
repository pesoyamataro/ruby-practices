#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

MAX_COLUMN = 3
SPACE_LENGTH = 3

def main
  files = search_files
  output(files)
end

def search_files
  option = OptionParser.new
  params = {}
  option.on('-a') { |v| params[:a] = v }
  path = option.parse!(ARGV)[0]
  return [path] if FileTest.file?(path.to_s)

  dirpath = ARGV.empty? ? Dir.getwd : path
  Dir.foreach(dirpath).sort.reject do |file|
    file.start_with?('.') unless params[:a]
  end
end

def output(files)
  row_count = (files.size.to_f / MAX_COLUMN).ceil
  display_width = adjust_width(files).max
  row_count.times do |i|
    MAX_COLUMN.times do |j|
      print ljust_kana(files[i + j * row_count], display_width)
      print "\n" if ((j + 1) % MAX_COLUMN).zero?
    end
  end
end

def adjust_width(file_chars)
  addition_count = 2
  file_chars.map do |file_char|
    count_chars(file_char, addition_count) + SPACE_LENGTH
  end
end

def ljust_kana(file_name, display_width)
  return '' if file_name.nil?

  addition_count = 1
  file_name.ljust(display_width - count_chars(file_name, addition_count))
end

def count_chars(file_name, addition_count)
  file_name.chars.sum { |c| c.ascii_only? ? addition_count - 1 : addition_count }
end

main
