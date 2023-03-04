#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

STDIN_COL_WIDTH = 7

def main
  options, argv_files = parse_argv
  file_details = argv_files.empty? ? [count_sentence($stdin.read)] : get_file_details(argv_files)
  output(file_details, options)
end

def parse_argv
  option = OptionParser.new
  options = {}
  option.on('-l') { |v| options[:line] = v }
  option.on('-w') { |v| options[:word] = v }
  option.on('-c') { |v| options[:byte] = v }
  argv_files = option.parse!(ARGV)
  if options.empty?
    options[:line] = true
    options[:word] = true
    options[:byte] = true
  end
  [options, argv_files]
end

def get_file_details(file_names)
  file_names.map do |file_name|
    file_content = File.read(file_name)
    count_sentence(file_content, file_name)
  end
end

def count_sentence(sentence, file_name = nil)
  {
    line: sentence.lines.count,
    word: sentence.split(/\s+/).size,
    byte: sentence.length,
    name: file_name
  }
end

def output(file_details, options)
  total_value = calc_total(file_details)
  col_width = calc_col_width(file_details, total_value)
  file_details.each do |file_detail|
    print_detail_value(file_detail, col_width, options)
    print "#{file_detail[:name]}\n"
  end
  return if file_details.size == 1

  print_detail_value(total_value, col_width, options)
  print "total\n"
end

def calc_total(file_details)
  total_line = 0
  total_word = 0
  total_byte = 0
  file_details.each do |file_detail|
    total_line += file_detail[:line]
    total_word += file_detail[:word]
    total_byte += file_detail[:byte]
  end
  {
    line: total_line,
    word: total_word,
    byte: total_byte
  }
end

def calc_col_width(file_details, total_value)
  file_details[0][:name].nil? ? STDIN_COL_WIDTH : total_value.values.max.to_s.length
end

def print_detail_value(detail_value, col_width, options)
  detail_value.each do |key, value|
    print "#{value.to_s.rjust(col_width)} " if options[key]
  end
end

main
