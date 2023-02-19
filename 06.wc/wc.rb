#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

STDIN_COL_WIDTH = 7

def main
  params, argv_files = parse_argv
  detail_files = argv_files.is_a?(Array) ? get_detail_files(argv_files) : [get_detail_stdin(argv_files)]
  output(detail_files, params)
end

def parse_argv
  option = OptionParser.new
  params = {}
  option.on('-c') { |v| params[:c] = v }
  option.on('-w') { |v| params[:w] = v }
  option.on('-l') { |v| params[:l] = v }
  argv_files = option.parse!(ARGV) == [] ? $stdin.read : option.parse!(ARGV)
  if params == {}
    params = {
      c: true,
      w: true,
      l: true
    }
  end
  [params, argv_files]
end

def get_detail_files(argv_files)
  argv_files.map do |argv_file|
    full_path = File.join(File.dirname(argv_file), File.basename(argv_file))
    read_file = File.read(full_path)
    {
      byte: File.size(full_path).to_s,
      name: argv_file == full_path ? full_path : argv_file
    }.merge(count_line_word(read_file))
  end
end

def get_detail_stdin(argv_stdin)
  {
    byte: argv_stdin.size.to_s
  }.merge(count_line_word(argv_stdin))
end

def count_line_word(read_file)
  {
    line: read_file.lines.count.to_s,
    word: read_file.split(/\s+/).size.to_s
  }
end

def output(detail_files, params)
  total_value = calc_total(detail_files)
  col_width = calc_col_width(detail_files, total_value)
  detail_files.each do |detail_file|
    output_value(detail_file, col_width, params)
    print "#{detail_file[:name]}\n"
  end
  return if detail_files.size == 1

  output_value(total_value, col_width, params)
  print "total\n"
end

def calc_total(detail_files)
  total_line = []
  total_word = []
  total_byte = []
  detail_files.each do |detail_file|
    total_line << detail_file[:line].to_i
    total_word << detail_file[:word].to_i
    total_byte << detail_file[:byte].to_i
  end
  {
    line: total_line.sum.to_s,
    word: total_word.sum.to_s,
    byte: total_byte.sum.to_s
  }
end

def calc_col_width(detail_files, total_value)
  detail_files.map do |detail_file|
    detail_file[:name].nil? ? STDIN_COL_WIDTH : total_value.values.max_by(&:length).length
  end.max
end

def output_value(detail_value, col_width, params)
  print "#{detail_value[:line].rjust(col_width)} " if params[:l]
  print "#{detail_value[:word].rjust(col_width)} " if params[:w]
  print "#{detail_value[:byte].rjust(col_width)} " if params[:c]
end

main
