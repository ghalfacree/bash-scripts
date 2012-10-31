#!/bin/bash
# Script to fix corrupt GPS dates from Android Camera App.
# Requires: perl, libimage-exiftool-perl

echo WARNING: About to overwrite GPS Date tag on all JPEG images.
read -p "Enter 'y' to continue, or any other key to quit. "
  [ "$REPLY" == "y" ] || exit 1

echo Correcting GPS Date tag, please wait...
for i in *.jpg
do
  exiftool -m -GPSDateStamp=`exiftool -exif:DateTimeOriginal "$i" | cut -d" " -f17` "$i"
done
echo Correction complete.
