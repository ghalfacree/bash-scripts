#!/bin/bash

echo This script is obsolete, thanks to the development of an official
echo Internet Archive tool which can handle bulk downloading of
echo collections and individual files. The script remains intact for
echo historical purposes but to do what you\'re trying to do
echo you should instead grab the official tool from here:
echo
echo https://github.com/jjjake/internetarchive
echo
exit 0

# Pick your filetype here. Examples: mp4, mp3, epub, pdf, txt
filetype=mp4

if [ "$1" = "" ]; then
  echo USAGE: archivedownload.sh collectionname
  echo See Archive.org entry page for the collection name.
  echo Collection name must be entered exactly as shown: lower case, with hyphens.
  exit
fi
echo Downloading list of entries for collection name $1...
#wget -nd -q "http://archive.org/advancedsearch.php?q=collection%3A$1&fl%5B%5D=identifier&sort%5B%5D=identifier+asc&sort%5B%5D=&sort%5B%5D=&rows=9999&page=1&callback=callback&save=yes&output=csv" -O identifiers.txt
wget -nd -q "https://archive.org/advancedsearch.php?q=$1&fl%5B%5D=identifier&sort%5B%5D=identifier+asc&sort%5B%5D=&sort%5B%5D=&rows=9999&page=1&callback=callback&save=yes&output=csv" -O identifiers.txt
echo Processing entry list for wget parsing...
tail -n +2 identifiers.txt | sed 's/"//g' > processedidentifiers.txt
if [ "`cat processedidentifiers.txt | wc -l`" = "0" ]; then
  echo No identifiers found for collection $1. Check name and try again.
  rm processedidentifiers.txt identifiers.txt
  exit
fi
echo Beginning wget download of `cat processedidentifiers.txt | wc -l` identifiers...
wget -r -H -nc -np -nH -nd -e robots=off --max-redirect 0 --domains archive.org --exclude-domains blog.archive.org -i processedidentifiers.txt -B 'http://archive.org/download/' -A .$filetype
if ls -U *_text.pdf > /dev/null 2>&1; then
  echo Found text-format PDFs, moving into text/ directory...
  if [ -d text ]; then
    mv *_text.pdf text/
  else
    mkdir text
    mv *_text.pdf text/
  fi
  echo Move complete.
fi
echo Deleting temporary files...
rm identifiers.txt processedidentifiers.txt
echo Complete.
