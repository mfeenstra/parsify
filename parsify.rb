#!/usr/bin/env ruby

SYNTAX = "\n\n* syntax:\n\t#{$0.split('/').last} " \
         "\t<audacity_labels.txt> <spotify_playlist.png>".freeze

if ( ARGV[0].nil? ||
     ARGV[1].nil? ||
     !File.exist?(ARGV[0]) ||
     !File.exist?(ARGV[1])
  ) then
  raise SYNTAX
end

wd = Dir.pwd
audacity_labels_file = ARGV[0].to_s
playlist_png = ARGV[1].to_s
root_folder = __dir__

def uid(len = 5)
  random_seed = -> { rand(36 ** 100).to_s(16).to_s }
  rando = -> (len) { ary = []; len.times do
    r = Random.new(Time.now.to_i * random_seed.call.to_i)
    ary << r.rand(0..15).to_s(16) end
    ary.join }
  return rando.call(len)
end

my_uuid = uid
# audicity labels export has broken linefeeds
labels_fixed = File.read(audacity_labels_file).gsub("\r", "\n")
File.write("labels.#{my_uuid}.txt", labels_fixed)

system("#{root_folder}/lib/pngs2pdf #{playlist_png}")
system("#{root_folder}/lib/do_parse.rb output.pdf labels.#{my_uuid}.txt")
