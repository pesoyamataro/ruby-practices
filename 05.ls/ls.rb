#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

MAX_COLUMN = 3
SPACE_LENGTH = 3

def main
  files = search_files
  row_count = (files.size.to_f / MAX_COLUMN).ceil
  display_width = ajust_width(files).max + SPACE_LENGTH
  output(row_count, files, display_width)
end

def search_files
  files = []
  if ARGV.empty?
    dirpath = Dir.getwd
  elsif Dir.exist?(ARGV[0])
    dirpath = ARGV[0]
  elsif FileTest.exist?(ARGV[0])
    files << ARGV[0]
  end

  if files.empty?
    Dir.foreach(dirpath) do |file|
      files << file unless file.start_with?('.')
    end
  end
  files.sort
end

def output(max_row, files_name, frame_width)
  max_row.times do |i|
    MAX_COLUMN.times do |j|
      print ljust_kana(files_name[i + j * max_row], frame_width) unless files_name[i + j * max_row].nil?
      print "\n" if ((j + 1) % MAX_COLUMN).zero?
    end
  end
end

def ajust_width(files_str)
  addition_count = 2
  files_str.map do |file_str|
    judge_ascii(file_str, addition_count)
  end
end

def ljust_kana(file_name, max_width)
  addition_count = 1
  file_name.ljust(max_width - judge_ascii(file_name, addition_count))
end

def judge_ascii(str, char_count)
  str.chars.sum { |c| c.ascii_only? ? char_count - 1 : char_count }
end

main
