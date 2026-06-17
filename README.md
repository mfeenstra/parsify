# parsify

Effortlessly split songs, with ID, from a recorded Spotify music stream.  Save songs with artist, title, and album in the filename.  Create tags automatically.

Designed for lossless FLAC audio as exported with Audacity. Also works with MP3.

<a href="mailto:matt.a.feenstra@gmail.com">matt.a.feenstra@gmail.com</a>

License: GPLv3

## Prerequisites

- Audacity
- ruby
- python3
- tesseract
- [metaflac](https://github.com/xiph/flac.git)


## 1.0 - Record a Spotify music playlist using Audacity

Recording lossless music from Spotify is possible on all desktop platforms.  (Windows, OSX, Linux and others)

- When recording, do
  - use a Spotify playlist
  - record/play in sequential order, sorted (A-Z) by **title**
  - maintain silence between the songs (no crossfade)
  - 20 songs per recording is ideal
  - leave the equalizer flat
  - turn off repeat and shuffle
  - avoid clippping of the audio
    - leave Spotify volume ~98%
    - adjust Audacity recording volume while visually inspecting the VU Meter. Maximize dynamic range and avoid touching the red. The meter should be within the green / yellow / orange.
  - (optional) normalize volume with an algorithm like [Platinum Notes](https://mixedinkey.com/platinum-notes/)

- Screenshot your playlist
  - <u>*column order:*</u> 1. __Artist__, 2. **Title**, 3. **Album**, 4. **Duration**
  - screenshot and save as <u>PNG</u> (`screenshot1.png`)
    - NOTE: avoid the column headers, mouse cursor, or other objects.  Capture only the rows

## 2.0 - Use Audacity's <u>**Analyze**</u> and <u>**Label**</u> features

- Identify the song boundaries
  - Load, select and highlight your entire recorded stream
  - Go to: _*Analyze*_ -> _*Label Sounds...*_

<u>**Important!**</u> - Adjust the below parameters until the number of **analyzed labels** is the **same** as the **number of songs** in your playlist, ie:

- **# labels** == **total songs**

- Example Parameters (fine tune as necessary)
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
  #### Wait for Analyze to complete.
- Go to: **Edit** -> **Labels** -> **Label Editor** -> **Export** -> **Save as:** `Labels 1.txt`

## 3.0 - Use `parsify.rb` and Generate New Labels

- Now we have the 2 files needed
  - `Labels 1.txt` representing the time boundaries for 20 recorded songs
  - `screenshot1.png` for these 20 songs, showing the artists, titles, albums, durations (optional) from the Spotify Playlist

- Use `parsify.rb` to generate a `new_labels.txt` file which will include artist, title, album, etc, at the same time boundaries
  - <u>**First time setup only**</u>
      ```bash
      # create Python environment and install dependencies
      python3 -m venv .venv
      source .venv/bin/activate
      pip install -r requirements.txt
      gem install colorize fileutils uri
      ```
  - <u>Environment</u>
    ```bash
    source .venv/bin/activate
    ```
  - <u>Do the needful</u>
    ```bash
    parsify.rb 'Labels 1.txt' screenshot1.png
    ```
    - this will output a labels file as `new_labels.txt` for import to Audacity, step 4
  - (optional) Save playlist(s) as PDF
    ```bash
    lib/pngs2pdf <*.png>
    ```
     - concatenates PNGs sequentially to generate a single PDF.  This is how parsify does optical character recognition with Tesseract

## 4.0 - Split Songs with ID's in the filename

- Back in Audacity, click the old label set (left of screen) and *delete* it
- Import the new labels you just created (`new_labels.txt`)
  - **Edit** -> **Labels** -> **Label Editor** -> **Delete existing row(s)** -> **Import** (`new_labels.txt`)
- Confirm that _only one_ label set exists for the stream (left of screen)
- Go to **File** -> **Export Audio..** -> 
  - **Export Range:** -> **Multiple Files** -> the below 2 forms will appear:
  - Ensure the bottom left form **Split files based on:** -> **Labels** is selected
  - Ensure the bottom right form **Name files:** -> **Using Label/Track Name** is selected
- Click **Export** and done

## 5.0 - Write metadata to FLAC files

- Fix filenames
  ```bash
  cd ~/Music/Audacity/Exports
  fix_flac_filenames.rb *.flac
  ```
- Write metadata
  ```bash
  mk_flac_tags.rb *.flac  
  ```
- (optional) Validate New Tags
  ```bash
  for f in *.flac; do metaflac --list "$f"; done
  ```

## (MP3 alternative) - Use [mp3tag](https://mp3tag.de) to write the ID3 tag
  - Windows 10 or 11
  - Open music folder, select all songs, right click **Convert filename** -> **Tag**
  - the delimiter is `' - '` space/hyphen/space
  - example naming mask: `%title% - %artist% - %album%.flac`

-----

That's all, folks!
