#!/bin/bash
echo Updating local Nexus 4 image archive...
rsync -e "ssh -c arcfour" -av --progress blacklaw.homedns.org:/media/ExternalDrives/NexusBackup/DCIM/ /media/Data/Photos/Nexus\ 4/DCIM/
echo Synchronising remote photo archive...
rsync -e "ssh -c arcfour" -av --delete --progress /media/Data/Photos/ blacklaw.homedns.org:/media/ExternalDrives/Photos/
echo Synchronising remote music archive...
rsync -e "ssh -c arcfour" -av --delete --progress /media/Data/My\ Music/ blacklaw.homedns.org:/media/ExternalDrives/Music/
echo "Synchronising remote video archive..."
rsync -e "ssh -c arcfour" -av --delete --progress /media/Data/Videos/ blacklaw.homedns.org:/media/ExternalDrives/Videos/
echo Backup complete.
