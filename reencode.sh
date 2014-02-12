#|/bin/bash
# Script to re-encode MP3 files my Negear MP101 doesn't like
OLDIFS=$IFS
IFS=$(echo "\n")
[ "`exiftool \"$1\" | grep Encoder | cut -d: -f 2`" = " LAME3.98r" ] && echo \"$1\"
IFS=$OLDIFS
