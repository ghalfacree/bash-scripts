#!/bin/bash
# Transfer a file from the Amstrad NC100 using the Xmodem protocol

if [ "$1" = "" ]; then
  echo USAGE: nc100transfer.sh filename
  exit
fi
echo Saving $1...
rx $1 < /dev/ttyWCH0 > /dev/ttyWCH0
echo Removing control characters from $1...
sed -i s/[[:cntrl:]]//g $1
echo File $1 transferred successfully.
