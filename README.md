# parsify

Effortlessly split songs, with ID, from a recorded Spotify music stream.  Save songs with artist, title, and album in the filename.  Create ID3 tags automatically.

<a href="mailto:matt.a.feenstra@gmail.com">matt.a.feenstra@gmail.com</a>

## Prerequisites

- Audacity
- ruby
- python3
- tesseract

## 1. Record a Spotify music playlist using Audacity

Recording loss-less music from Spotify is possible on all desktop platforms.  (Windows, OSX, Linux and others)

- When recording, do
  - use a Spotify playlist
  - record/play in sequential order, sorted (A-Z) by *title*
  - maintain silence between the songs (no crossfade)
  - 20 songs per stream

- Screenshot your playlist
  - *column order:* _Title_, _Artist_, _Album_, _Duration_
  - capture as `.png` image format (20 songs per image)
  - avoid the column headers, mouse cursor, or other objects.  Just the table of ordered song information.

## 2. Use Audacity's analyze and label feature to split the songs

- Identify the song boundaries
  - Load, select and highlight your entire recorded stream
  - Go to: *Analyze* -> *Label Sounds...*

- Example Parameters (adjust as necessary)
  - Threshold level: `-59.0`
  - Threshold measurement: `Peak level`
  - Minimum silence duration: `0.4 sec`
- _*Important!*_ The following value should be _slightly_ less than the duration of your shortest song.  ie: if the shortest song is 2 min 30 sec, set the minimum label interval to 2 min 25 sec.
  - Minimum label interval: `00 h 02 m 25.000 s`
  - Region Type: `Region around sounds`
  - Minimum leading silence: `00 h 00 m 00.000 s` (default)
  - Minimum trailing silence: `00 h 00 m 00.000 s` (default)
  - Label text: `Sound ##1`
  - Click -> *Apply*
- Settings may be saved with the upper left `Presets & settings` button. 
- Label boundaries may need to be adjusted depending upon your recording.  For example, long silence in a song can be mistaken for a song boundary.

### Now, click and _select_ your set of labels on the left of the screen.

### Go to *Edit* -> *Labels* -> *Label Editor* -> *Export* -> Save as `labels.txt`

## 3. Use `parsify.rb` to generate new labels

- Now we have the 2 files needed
- `labels.txt` representing the time boundaries for 20 recorded songs
- `screenshot1.png` for these 20 songs, showing the artists, titles, albums, durations (optional) from the Spotify Playlist

- Use `parsify.rb` to generate a _new_ labels file that includes artist, title, album, etc
  - _*(first time setup)*_ Python environment
    ```py
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    ```
  - `source .venv/bin/activate`
  - `parsify.rb labels.txt screenshot1.png`
    - this will output a labels file like `labels.{random hash}.txt` for Audacity step 4

## 4. Export individual songs with the ID as filename

- Back in Audacity, click the old label set (left of screen) and *delete* it
- Import the new `labels.{hash}.txt` data, *Edit* -> *Labels* -> *Label Editor* -> *Import*
- Confirm that _only one_ label set exists for the stream (left of screen).  Sometimes there is an empty set, remove it
- Go to *File* -> *Export Audio..* -> 
  - *Export Range:* -> *Multiple Files*
  - Ensure the bottom left form *Split files based on:* -> *Labels* is selected
  - Ensure the bottom right form *Name files:* -> *Using Label/Track Name* is selected
- Click *Export* and done

## (optional) Use [mp3tag](https://mp3tag.de) to write the ID3 tag
  - Windows 10 or 11
  - Open music folder, select all songs, right click *Convert filename -> Tag*
  - delimiter is `' - '` space/hyphen/space
  - example naming mask: `%title% - %artist% - %album%.flac`

-----

That's all, folks!
