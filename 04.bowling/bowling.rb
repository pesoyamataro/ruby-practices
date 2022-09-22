#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
total_score = 0
frames = []
shots = []

score.split(',').each do |n|
  n = 10 if n == 'X'
  shots << n.to_i
  if frames.size <= 9 && (shots.first == 10 || shots.size == 2)
    frames << shots
    shots = []
  elsif frames.size == 10 # 最終フレーム3投目処理
    frames.last << n.to_i
  end
end

10.times do |i|
  total_score += frames[i - 1].sum
  if frames[i - 1].sum == 10 && frames[i - 1].size == 2 # スペア
    total_score += frames[i].first
  elsif frames[i - 1].size == 1 # ストライクの場合、一旦次フレームを加算
    total_score += frames[i].sum
    case frames[i].size
    when 3 # 9フレーム目ストライクの場合、10フレーム目の3投目分を減算
      total_score -= frames[i].last
    when 1 # 2連続ストライクの場合、2フレーム先の1投目を追加
      total_score += frames[i + 1].first
    end
  end
end

puts total_score
