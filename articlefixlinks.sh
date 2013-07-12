#!/bin/bash
# Fix broken links in ER articles prior to submission.
# Looks for and corrects cases where a " has come out as a 2 due to rapid typing

cd /home/blacklaw/Dropbox/Work/expertreviews/articles
for i in *.txt; do
  sed -i 's/2>/">/g' $i
  sed -i 's/href=2/href="/g' $i
  sed -i 's/<\/>/<\/a>/g' $i
done
echo Files processed, links fixed.
exit
