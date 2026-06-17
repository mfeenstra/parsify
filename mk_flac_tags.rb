#!/usr/bin/env ruby
#
# Convert a FLAC file name to a VORBIS comments (flac's version of
# ID3 metadata). Requires the flac project's metaflac from:
# https://github.com/xiph/flac
#
# FLAC files are expected to be in the following format.  Note that there
# is no genre because Spotify does not provide one.  The characters after
# Album are ignored. 
#
# Artist - Title - Album Artist(s) - Album - ....flac
#
################################################################################
require 'colorize'

if ARGV.size.eql?(0)
  puts "\nsyntax:\n\t#{$0}\t<flac files>\n\n"
  exit 1
end

flacfiles = ARGV.map { |f| f.to_s if File.exist?(f) }
count = 0; err = 0
puts "BEGIN: ".yellow + "Writing VORBIS tag comments ".light_blue +
             "(#{flacfiles.size} files)\n\n".light_green

flacfiles.each do |f|
  parts = f.split(' - ')
  # no album or missing title
  unless parts[0].nil?
    parts[1].nil? ? parts[1] = '' : ()
    parts[2].nil? ? parts[2] = '' : ()
    parts[3].nil? ? parts[3] = '' : ()
  else
    puts "WARNING: invalid name format, skipping: ".red + "#{f}".light_white
    err += 1
    next
  end

  artist, title, albumartist, album = parts[0..3]
  album.gsub!('.flac', '')
  begin
    # delete any existing metadata
    system("metaflac --remove-all '#{f}'")
    system("metaflac " \
           "--set-tag='ALBUM=#{album}' " \
           "--set-tag='ALBUMARTIST=#{albumartist}' " \
           "--set-tag='ARTIST=#{artist}' " \
           "--set-tag='TITLE=#{title}' " \
           "'#{f}'"
          ) && puts("* ".yellow + "tagged: ".green + f.light_blue)
    count += 1
  rescue => e
    puts "#{e.message}".light_red
    err += 1
  end
end

puts "\n\ncomplete: ".light_cyan + "#{count} updated".light_green + ',' +
    " #{err} skipped".light_magenta + "\n\n"
exit 0