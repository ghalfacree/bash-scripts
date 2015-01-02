#/bin/bash
# Right, let's get those TOSEC filenames organised, shall we?
SAFEIFS=$IFS
IFS=$(echo -en "\n\b")

for i in `find . -iname "*adf"`; do

  # Some files are read-only, so we need to fix that
  chmod +w "$i"

  # Check filename for bad dump markers
  if grep -q '\[a[0-9]' <<< $i || grep -q '\[a\]' <<< $i ; then
    echo WARNING - Alternate copy found for $i - deleted.
    rm "$i"
    continue
  fi
  if grep -q '\[o' <<< $i; then
    echo DELETION - Overdump found in $i.
    rm "$i"
    continue
  fi
  if grep -q '\[m' <<< $i; then
    echo DELETION - Modified dump found in $i.
    rm "$i"
    continue
  fi
  if grep -q '\[h' <<< $i; then
    echo DELETION - Hacked variant found in $i.
    rm "$i"
    continue
  fi
  if grep -q '\[u' <<< $i; then
    echo DELETION - Underdump found in $i.
    rm "$i"
    continue
  fi
  if grep -q '\[v' <<< $i; then
    echo  DELETION - Virus damage found in $i.
    rm "$i"
    continue
  fi
  if grep -q '\[b' <<< $i; then
    if grep -q '\[b\ ' <<< $i; then
      echo DELETION - Bad dump found in $i.
      rm "$i"
      continue
    fi
  fi

  # Translation tests!
  if grep -q '\[tr' <<< $i; then
    if grep -q -v '\[tr en' <<< $i; then
      echo DELETION - Non-English translation found in $i.
      rm "$i"
      continue
    fi
  fi    
  
  # Test to see if image is part of a multi-disk set
  if grep -q \(Disk\  <<< $i; then
    locationvar=`echo $i | grep -b -o \(Disk\  | cut -d\: -f1 | sed 's/ *$//'`
    disknumber=`echo ${i:$locationvar} | cut -d\( -f2 | cut -d\) -f1 | sed 's/ *$//'`
    gamename=`echo $i | cut -d\( -f1 | sed 's/ *$//'`
    mv "$i" "$gamename - $disknumber.adf"
    echo Tidied $gamename - $disknumber.adf
  # If not, just rename
  else
    gamename=`echo $i | cut -d\( -f1 | sed 's/ *$//'`
    mv "$i" "$gamename.adf"
    echo Tidied $gamename.adf
  fi
done

IFS=$SAVEIFS
