#!/usr/bin/env bash

echo Copying files to Remarkable...

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

for i in *pdf
do
	pdf2remarkable.sh "$i"
done

IFS=$SAVEIFS

pdf2remarkable.sh -r

exit 0
