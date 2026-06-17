#!/usr/bin/env ruby
######################################################################
# This utility decodes any HTML URL encoded characters, and removes  #
# high-bit ASCII that could be in the filenames.                     #
######################################################################
require 'uri'
require 'fileutils'
require 'colorize'

remove_platinum_notes_extension = true
remove_duration_field = true

files = nil
if ARGV.size.eql?(0)
  files = Dir.glob('*.flac')
else 
  files = ARGV.map { |f| f.to_s }
end
raise("no files specified!".light_red) if files.size.eql?(0)

def sanitize(str)
  str.unpack("U*").map { |i| i unless i > 255 }.compact.pack("U*")
end

files.each do |f|
  new_f = sanitize(URI.decode_www_form_component(f)).tr("\n", ' ')
  new_f.gsub!(/\ \ +/, ' ')
  remove_platinum_notes_extension ? new_f.gsub!('_PN', '') : ()
  remove_duration_field ? new_f.gsub!(/\ -\ \d{1,4}.\d{0,3}.flac$/, '.flac') : ()
  new_f.gsub!(/.+\-.flac$/, '.flac')
  begin
    puts '* '.yellow + f.green + "\t->\t".yellow + new_f.light_blue
    FileUtils.mv(f, new_f)
  rescue => e
    puts "\t#{e.class.to_s.magenta}: " + e.message.light_cyan
  end
end
