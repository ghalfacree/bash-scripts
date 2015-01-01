#!/bin/bash
# Hacky? Yes. Worked? Yes. Don't judge me!
SAFEIFS=$IFS
IFS=$(echo -en "\n\b")
for i in *mp3;
do
  #echo `$i|cut -d\( -f1`
  directory="`echo $i|cut -d\( -f1 | sed 's/ *$//'`"
  if [ ! -d "$directory" ]; then
    mkdir "$directory"
    echo Directory $directory created.
  fi
  mv $i $directory/`echo $i|cut -d[ -f1 | sed 's/ *$//'`.mp3
  echo Moved $i into $directory, renamed.
done
IFS=$SAVEIFS
