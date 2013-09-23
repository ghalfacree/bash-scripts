#!/bin/bash

OUTF=${1%.flac}.mp3
ARTIST=$(metaflac "$1" --show-tag=ARTIST | sed s/.*=//g)
TITLE=$(metaflac "$1" --show-tag=TITLE | sed s/.*=//g)
ALBUM=$(metaflac "$1" --show-tag=ALBUM | sed s/.*=//g)
GENRE=$(metaflac "$1" --show-tag=GENRE | sed s/.*=//g)
TRACKNUMBER=$(metaflac "$1" --show-tag=TRACKNUMBER | sed s/.*=//g)
DATE=$(metaflac "$1" --show-tag=DATE | sed s/.*=//g)
flac -cd "$1" | lame -h --vbr-new --preset extreme - "$OUTF"
id3 -t "$TITLE" -T "${TRACKNUMBER:-0}" -a "$ARTIST" -A "$ALBUM" -y "$DATE" -g "${GENRE:-12}" "$OUTF"
