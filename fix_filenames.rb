#!/usr/bin/env ruby
######################################################################
# This utility decodes any HTML URL encoded characters, and removes  #
# high-bit ASCII that could be in the filenames.                     #
######################################################################
require 'uri'

files = nil
if ARGV.size.eql?(0)
  files = Dir.glob('*.flac')
else 
  files = ARGV.map { |f| f.to_s }
end
raise("no files specified!") if files.size.eql?(0)

def sanitize(str)
  str.unpack("U*").map { |i| i unless i > 255 }.compact.pack("U*")
end

files.each do |f|
  new_f = sanitize(URI.decode_www_form_component(f)).tr("\n", ' ')
  File.rename(f, new_f)
end
