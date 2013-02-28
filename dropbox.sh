#!/bin/bash
if ls -1 /home/blacklaw/Dropbox/Work/expertreviews/articles/*txt > /dev/null 2>&1
then
  bzip2 /home/blacklaw/Dropbox/Work/expertreviews/articles/*txt && mv ~/Dropbox/Work/expertreviews/articles/*bz2 ~/Dropbox/Work/expertreviews/articles/old/
fi
rsync -e "ssh -c arcfour" -av --progress --delete /home/blacklaw/Dropbox/ blacklaw.homedns.org:/media/Seagate320/Dropbox/
