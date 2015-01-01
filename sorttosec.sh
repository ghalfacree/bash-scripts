#/bin/bash
# Right, let's get those TOSEC filenames organised, shall we?
SAFEIFS=$IFS
IFS=$(echo -en "\n\b")

for i in `find . -iname "*adf"`; do
  if grep -q \(Disk\  <<< $i; then
    locationvar=`echo $i | grep -b -o \(Disk\  | cut -d\: -f1 | sed 's/ *$//'`
    disknumber=`echo ${i:$locationvar} | cut -d\( -f2 | cut -d\) -f1 | sed 's/ *$//'`
    gamename=`echo $i | cut -d\( -f1 | sed 's/ *$//'`
    echo mv "$i" "$gamename - $disknumber.adf"
  else
    gamename=`echo $i | cut -d\( -f1 | sed 's/ *$//'`
    echo mv "$i" "$gamename.adf"
  fi
done
IFS=$SAVEIFS
