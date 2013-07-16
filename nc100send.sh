#!/bin/bash
# Transfer a file to the Amstrad NC100 using the Xmodem protocol

if [ "$1" = "" ]; then
  echo USAGE: nc100send.sh filename
  exit
fi
echo Replacing £ symbols with placeholder...
cp $1 /tmp/nc100.temp
sed -i 's/£/symbolforGBPgohere/g' /tmp/nc100.temp
echo Converting $1 to 7-bit ASCII...
iconv -f UTF-8 -t ASCII//TRANSLIT -o /tmp/nc100.ascii /tmp/nc100.temp
echo Replacing £ symbols with NC100 codepage equivalent...
sed -i 's/symbolforGBPgohere/\o234/g' /tmp/nc100.ascii
echo Sending $1...
sx /tmp/nc100.ascii > /dev/ttyWCH0 < /dev/ttyWCH0
echo Cleaning up...
rm /tmp/nc100.ascii /tmp/nc100.temp
echo File $1 transferred successfully.
