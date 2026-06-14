#!/usr/bin/env ruby

@songs = ARGV[0] || 'output.pdf'
@times = ARGV[1] || 'analyzed.txt'

def sanitize(str)
  str.unpack('U*').reject { |i| i > 255 }.pack('U*')
end

def raw_ocr(pdf)
  cmd = "source #{__dir__}/../.venv/bin/activate && " \
        "#{__dir__}/table_ocr.py #{pdf} 2>pyerr.log"
  output = `#{cmd}`
  sanitize(output).split("\n")
end

def clean_tags(dirty_songs)
  delimiter_spaces = 20
  dirty_songs.map! { |l| l.gsub(/^\ +/, '').gsub(/^\d{1,4}\ +/, '').
                           gsub('-', '').gsub(/\ {20}+/, ' - ').
                           gsub(/\ +/, ' ').tr(';', ':').
                           tr('|', '').gsub('&', 'and').tr('"', '').
                           tr("'", '').tr('/', '+').gsub(/\ +/, ' ') }
  dirty_songs.map! do |tag|
    "#{albumartist(tag)} - #{tag}"
  end
  dirty_songs
end

def albumartist(tag)
  unless tag.split(' - ').size < 3 then
    name = tag.split(' - ')[1].split(',').first
    return name
  else
    return 'nil'
  end
end

# filenames
def map_durations(durations = @times)
  durations = File.readlines(duration_labels(durations), chomp: true).
                   map { |l| l.split("\r") }[0..1]
end

def name_labels(songs = @songs)
  tags = clean_tags(raw_ocr(songs))
end

# analyzed is the filename of the label duration from audacious
def duration_labels(f = @times)
  time_values = []
  durations = File.readlines(f, chomp: true)
  durations.each do |d|
    ary = d.split("\t")
    time_values << [ary[0],ary[1]]
  end
  time_values
end

def one_label(duration, name)
  "#{duration.first}\t#{duration.last}\t#{name}"
end

song_tags = name_labels(@songs)
song_times = duration_labels(@times)
new_labels = []
song_times.each_with_index do |duration, i|
  l = one_label(duration, song_tags[i])
  new_labels << l
end

puts new_labels.join("\n")
File.write('new_labels.txt', new_labels.join("\n")) && \
  puts('* wrote: new_labels.txt') && exit(0)
exit 1

