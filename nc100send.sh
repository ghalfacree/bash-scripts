#!/bin/bash
# Transfer a file to the Amstrad NC100 using the Xmodem protocol

if [ "$1" = "" ]; then
  echo USAGE: nc100send.sh filename
  exit
fi
echo Sending $1...
sx $1 > /dev/ttyWCH0 < /dev/ttyWCH0
echo File $1 transferred successfully.
