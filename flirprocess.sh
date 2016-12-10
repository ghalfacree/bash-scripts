#!/bin/bash
# Script to convert FLIR JPEG images into a bitmap and thermal image.

if [ "$1" = "" ]; then
  echo Error: no input filename specified.
  echo Usage: $0 inputfilename outputfilename
  exit 1
fi

if [ "$2" = "" ]; then
  echo Error: no output filename specified.
  echo Usage: $0 inputfilename outputfilename
  exit 2
fi

if [ ! -f $1 ]; then
  echo Error: input filename not found.
  exit 3
fi

exiftool $1 -b -EmbeddedImage > $2.dat
flir.php --resize 465 -i $1 -o $2.png
rm ir.png gradient.png palette.png raw.png
echo File converted!
exit
