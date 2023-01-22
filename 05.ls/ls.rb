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
  dirpath, all_files = FileTest.file?(argv_path) ? [File.dirname(argv_path), [File.basename(argv_path)]] : [argv_path, search_files(params, argv_path)]
  if params[:l]
    detail_files = get_detail_files(all_files, dirpath)
    total_size = detail_files.sum { |file_detail| file_detail[:block_size] } unless FileTest.file?(argv_path)
    output_detail(detail_files, total_size)
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
  argv_path = option.parse!(ARGV)[0] || Dir.getwd
  [params, argv_path]
end

def search_files(params, dirpath)
  file_names = Dir.foreach(dirpath).reject { |file| file.start_with?('.') && !params[:a] }.sort
  params[:r] ? file_names.reverse : file_names
end

def get_detail_files(file_names, dirpath)
  file_names.map do |file_name|
    fullpath = File.join(dirpath, '/', file_name)
    file_lstat = File.lstat(fullpath)
    {
      ftype: FTYPE[file_lstat.ftype],
      permission: join_filemode(file_lstat),
      nlink: file_lstat.nlink.to_s,
      uid: Etc.getpwuid(file_lstat.uid).name,
      gid: Etc.getgrgid(file_lstat.gid).name,
      file_size: File.size(fullpath).to_s,
      mtime: file_lstat.mtime.strftime('%_m月 %_d %_R'),
      file_name: file_name,
      block_size: file_lstat.blocks / 2 # 1ブロックサイズを512byte⇒1024byteに変換
    }
  end
end

def join_filemode(file_lstat)
  (-3..-1).map do |i|
    element_filemode = file_lstat.mode.to_s(8).slice(i)
    PERMISSIONS[element_filemode]
  end.join
end

def adjust_display_size(detail_files)
  all_nlink = []
  all_owner = []
  all_group = []
  all_file_size = []
  detail_files.each do |detail_file|
    all_nlink << detail_file[:nlink]
    all_owner << detail_file[:uid]
    all_group << detail_file[:gid]
    all_file_size << detail_file[:file_size]
  end
  {
    nlink: all_nlink.map(&:size).max,
    owner: all_owner.map(&:size).max,
    group: all_group.map(&:size).max,
    file_size: all_file_size.map(&:size).max
  }
end

def output_detail(detail_files, total_size)
  puts "合計 #{total_size}" unless total_size.nil?
  col_width = adjust_display_size(detail_files)
  detail_files.each do |detail_file|
    print detail_file[:ftype]
    print "#{detail_file[:permission]} "
    print "#{detail_file[:nlink].rjust(col_width[:nlink])} "
    print "#{detail_file[:uid].ljust(col_width[:owner])} "
    print "#{detail_file[:gid].ljust(col_width[:group])} "
    print "#{detail_file[:file_size].rjust(col_width[:file_size])} "
    print "#{detail_file[:mtime]} "
    print detail_file[:file_name]
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
