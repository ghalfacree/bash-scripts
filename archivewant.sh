#!/bin/bash
# Quick and dirty script to see if Archive.org wants a given ISBN.
# Uses the experimental 'do-we-want-it' API
# http://want.archive.org/

if [ "$1" = "" ]; then
  echo USAGE: archivewant.sh isbn-number
  echo ALT USAGE: archivewant.sh -f list-of-isbn-numbers.txt
  exit
fi
while getopts f: option; do
  case "$option"
    in
      f) FILENAME=$OPTARG;;
  esac
done
if [ "$FILENAME" = "" ]; then
  curl "http://want.archive.org/api?isbn=$1&human" && echo
else
  if [ -f $FILENAME ]; then
    for i in `cat $FILENAME`; do
      echo -n "$i: "
      curl "http://want.archive.org/api?isbn=$i&human"
      echo
    done
  else
    echo Error: file $FILENAME not found.
    exit
  fi 
fi
