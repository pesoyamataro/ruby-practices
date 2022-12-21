#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

MAX_COLUMN = 3
SPACE_LENGTH = 3
BLOCK_SIZE = 4096

PERMISSIONS = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

FTYPE = {
  'fifo' => 'p',
  'characterSpecial' => 'c',
  'directory' => 'd',
  'blockSpecial' => 'b',
  'file' => '-',
  'link' => 'l',
  'socket' => 's'
}.freeze

def main
  params, argv_path = separate_argv
  dirpath = argv_path || Dir.getwd
  simplex_file = true if FileTest.file?(argv_path.to_s)
  all_files = search_files(params, argv_path, dirpath, simplex_file)
  if params[:l]
    detail_array_files = get_detail_files(argv_path, all_files, dirpath, simplex_file) if params[:l]
    detail_display_size = adjust_display_size(detail_array_files)
    output_detail(detail_array_files, detail_display_size, simplex_file)
  else
    output_normal(all_files)
  end
end

def separate_argv
  option = OptionParser.new
  params = {}
  option.on('-a') { |v| params[:a] = v }
  option.on('-r') { |v| params[:r] = v }
  option.on('-l') { |v| params[:l] = v }
  [params, option.parse!(ARGV)[0]]
end

def search_files(params, argv_path, dirpath, simplex_file)
  return [argv_path] if simplex_file

  file_names = Dir.foreach(dirpath).reject { |file| file.start_with?('.') && !params[:a] }.sort
  params[:r] ? file_names.reverse : file_names
end

def get_detail_files(_argv_path, file_names, dirpath, simplex_file)
  detail_array_files = []
  file_names.map do |file_name|
    fullpath = simplex_file ? file_name : "#{dirpath}/#{file_name}"
    file_lstat = File.lstat(fullpath)
    detail_files = {}
    detail_files[:ftype] = FTYPE[file_lstat.ftype]
    element_permission = []
    -3.upto(-1) { |i| element_permission << PERMISSIONS[file_lstat.mode.to_s(8).slice(i)] }
    detail_files[:permission] = element_permission.join
    detail_files[:nlink] = file_lstat.nlink.to_s
    detail_files[:uid] = Etc.getpwuid(file_lstat.uid).name
    detail_files[:gid] = Etc.getgrgid(file_lstat.gid).name
    detail_files[:file_size] = File.size(fullpath).to_s
    detail_files[:mtime] = file_lstat.mtime.strftime('%_m月 %_d %_R')
    detail_files[:file_name] = file_name
    detail_files[:block_size] = file_lstat.blocks / 2 # 1ブロックサイズを512byte⇒1024byteに変換
    detail_array_files << detail_files
  end
  detail_array_files
end

def adjust_display_size(detail_array_files)
  all_nlink = []
  all_owner = []
  all_group = []
  all_file_size = []
  all_block_size = []
  detail_array_files.each do |detail_array_file|
    all_nlink << detail_array_file[:nlink]
    all_owner << detail_array_file[:uid]
    all_group << detail_array_file[:gid]
    all_file_size << detail_array_file[:file_size]
    all_block_size << detail_array_file[:block_size]
  end
  {
    space_nlink: all_nlink.map(&:size).max,
    space_owner: all_owner.map(&:size).max,
    space_group: all_group.map(&:size).max,
    space_file_size: all_file_size.map(&:size).max,
    total_size: all_block_size.sum
  }
end

def output_detail(file_all, detail_display_size, simplex_file)
  puts "合計 #{detail_display_size[:total_size]}" unless simplex_file
  file_all.each do |file_list|
    print file_list[:ftype]
    print "#{file_list[:permission]} "
    print "#{file_list[:nlink].rjust(detail_display_size[:space_nlink])} "
    print "#{file_list[:uid].ljust(detail_display_size[:space_owner])} "
    print "#{file_list[:gid].ljust(detail_display_size[:space_group])} "
    print "#{file_list[:file_size].rjust(detail_display_size[:space_file_size])} "
    print "#{file_list[:mtime]} "
    print file_list[:file_name]
    print "\n"
  end
end

def output_normal(all_files)
  row_count = (all_files.size.to_f / MAX_COLUMN).ceil
  display_width = adjust_width(all_files).max
  row_count.times do |i|
    MAX_COLUMN.times do |j|
      print ljust_kana(all_files[i + j * row_count], display_width)
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
