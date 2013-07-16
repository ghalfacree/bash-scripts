#!/bin/bash
# Transfer a file to or from the Amstrad NC100/NC150/NC200
# Includes codepage swapping and pound-symbol replacement.

case "$1" in

  rx)
    if [ "$2" == "" ]; then
      echo USAGE: $0 rx filename
      exit 1
    fi
    rx $2 < /dev/ttyWCH0 > /dev/ttyWCH0
    echo Removing control characters, mapping £ symbol...
    sed -i 's/[[:cntrl:]]//g;s/\o234/£/g' $2
    echo File $2 transferred and converted.
    ;;

  tx)
    if [ ! -e "$2" ]; then
      echo USAGE: $0 tx filename
      exit 1
    fi
    cp $2 /tmp/nc100.temp
    echo Converting codepage, mapping £ symbol...
    sed -i 's/£/symbolforGBPgohere/g' /tmp/nc100.temp
    echo Converting $2 to 7-bit ASCII...
    iconv -f UTF-8 -t ASCII//TRANSLIT -o /tmp/nc100.ascii /tmp/nc100.temp
    sed -i 's/symbolforGBPgohere/\o234/g' /tmp/nc100.ascii
    sx /tmp/nc100.ascii > /dev/ttyWCH0 < /dev/ttyWCH0
    echo Cleaning up...
    rm /tmp/nc100.ascii /tmp/nc100.temp
    echo File $2 converted and transferred.
    ;;

  *)
    echo $"USAGE: $0 {rx|tx} filename"
    exit 1
esac  
