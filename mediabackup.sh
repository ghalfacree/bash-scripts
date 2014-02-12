#!/bin/bash
echo Updating local Nexus 4 image archive...
rsync -av --progress altair:/media/ExternalDrives/Backups/Nexus4/DCIM/ /media/Data/Photos/Nexus\ 4\ KitKat/DCIM/
echo Synchronising remote photo archive...
rsync -av --delete --progress /media/Data/Photos/ altair:/media/ExternalDrives/Photos/
echo Synchronising remote music archive...
rsync -av --delete --progress /media/Data/My\ Music/ altair:/media/ExternalDrives/Music/
echo "Synchronising remote video archive..."
rsync -av --delete --progress /media/Data/Videos/ altair:/media/ExternalDrives/Videos/
echo Backup complete.
