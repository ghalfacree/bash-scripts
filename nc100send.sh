#!/bin/bash
# Transfer a file to the Amstrad NC100 using the Xmodem protocol

if [ "$1" = "" ]; then
  echo USAGE: nc100send.sh filename
  exit
fi
echo Converting $1 to 7-bit ASCII...
iconv -f UTF-8 -t ASCII//TRANSLIT -o /tmp/nc100.ascii $1
echo Sending $1...
sx /tmp/nc100.ascii > /dev/ttyWCH0 < /dev/ttyWCH0
echo Cleaning up...
rm /tmp/nc100.ascii
echo File $1 transferred successfully.
