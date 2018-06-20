#!/bin/bash

# What do you do when your device has a 256 file limit per directory?
# MAKE A METRIC ASS-LOAD OF DIRECTORIES!

for d in {A..Z}; do
  echo Splitting files in $d...
  cd $d
  mkdir /tmp/moving$d
  find . -maxdepth 1 -type f > /tmp/moving$d/filelist.txt
  split -l 254 /tmp/moving$d/filelist.txt /tmp/moving$d/split
  i=1
  for f in /tmp/moving$d/split*; do
    echo Moving batch $i...
    mkdir $i
    sed -i -e "s/\(.*\)/\"\1\"/" $f
    xargs -a $f mv -t $i/
    ((i++))
  done
  rm /tmp/moving$d/*
  rmdir /tmp/moving$d
  cd ..
done
exit 0 
