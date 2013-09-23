#! /bin/bash
#
# Script to back up the contents of /media/Seagate320/Dropbox
# Uses GPG encryption for security
# Keeps 1 week of data
# Uploads some files to external storage

tar c /media/Seagate320/Dropbox | gpg -e --batch -u "Gareth Robert Halfacree" -r "Gareth Robert Halfacree" > /media/Seagate320/backup/Dropbox_`date '+%Y%m%d'`.tar.gpg
rsync --bwlimit=60 -e "ssh -p 2510" /media/Seagate320/backup/Dropbox_`date '+%Y%m%d'`.tar.gpg halfacre@halfacree.co.uk:/home/halfacre/backups/DropboxBackup.tar.gpg
find /media/Seagate320/backup/Dropbox_*.tar.gpg -mtime 7 -delete
