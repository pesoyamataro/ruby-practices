#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

def main
  options, argv_files = parse_argv
  text_details = argv_files.empty? ? [get_text_detail($stdin.read)] : get_text_details(argv_files)
  output_lines(text_details, options)
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

def get_text_details(file_names)
  file_names.map do |file_name|
    file_sentense = File.read(file_name)
    get_text_detail(file_sentense, file_name)
  end
end

def get_text_detail(sentence, file_name = nil)
  {
    line: sentence.lines.count,
    word: sentence.split(/\s+/).size,
    byte: sentence.length,
    name: file_name
  }
end

def output_lines(text_details, options)
  total_value = calc_total(text_details)
  col_width = total_value.values_at(:line, :word, :byte).max.to_s.length
  text_details.each do |text_detail|
    output_line(text_detail, col_width, options)
  end
  return if text_details.size == 1

  output_line(total_value, col_width, options)
end

def calc_total(text_details)
  total = Hash.new { |h, k| h[k] = 0 }
  text_details.each do |text_detail|
    total[:line] += text_detail[:line]
    total[:word] += text_detail[:word]
    total[:byte] += text_detail[:byte]
  end
  total[:name] = 'total'
  total
end

def output_line(detail_value, col_width, options)
  detail_value.each do |key, value|
    print "#{value.to_s.rjust(col_width)} " if options[key]
  end
  print detail_value[:name] unless detail_value[:name].nil?
  print "\n"
end

main
