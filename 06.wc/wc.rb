#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

STDIN_COL_WIDTH = 7

def main
  options, argv_files = parse_argv
  detail_files = argv_files.empty? ? [read_detail_stdin] : get_detail_files(argv_files)
  output(detail_files, options)
end

def parse_argv
  option = OptionParser.new
  params = {}
  option.on('-c') { |v| params[:c] = v }
  option.on('-w') { |v| params[:w] = v }
  option.on('-l') { |v| params[:l] = v }
  argv_files = option.parse!(ARGV)
  if params.empty?
    params = {
      c: true,
      w: true,
      l: true
    }
  end
  [params, argv_files]
end

def get_detail_files(file_names)
  file_names.map do |file_name|
    content_file = File.read(file_name)
    count_sentence(content_file, file_name)
  end
end

def read_detail_stdin
  count_sentence($stdin.read)
end

def count_sentence(sentence, file_name = nil)
  {
    line: sentence.lines.count.to_s,
    word: sentence.split(/\s+/).size.to_s,
    byte: sentence.length.to_s,
    name: file_name
  }
end

def output(detail_files, options)
  total_value = calc_total(detail_files)
  col_width = calc_col_width(detail_files, total_value)
  detail_files.each do |detail_file|
    output_value(detail_file, col_width, options)
    print "#{detail_file[:name]}\n"
  end
  return if detail_files.size == 1

  output_value(total_value, col_width, options)
  print "total\n"
end

def calc_total(detail_files)
  total_line = 0
  total_word = 0
  total_byte = 0
  detail_files.each do |detail_file|
    total_line += detail_file[:line].to_i
    total_word += detail_file[:word].to_i
    total_byte += detail_file[:byte].to_i
  end
  {
    line: total_line.to_s,
    word: total_word.to_s,
    byte: total_byte.to_s
  }
end

def calc_col_width(detail_files, total_value)
  detail_files[0][:name].nil? ? STDIN_COL_WIDTH : total_value.values.max_by(&:length).length
end

def output_value(detail_value, col_width, options)
  print "#{detail_value[:line].rjust(col_width)} " if options[:l]
  print "#{detail_value[:word].rjust(col_width)} " if options[:w]
  print "#{detail_value[:byte].rjust(col_width)} " if options[:c]
end

main
