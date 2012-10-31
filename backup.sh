#! /bin/bash

# Backup
# V3

for i in /home/ /media/Data/ ; do
	rsync -a -h --del --ignore-errors --progress ${i} /media/blacklaw/Backup01/New\ Backups${i}
done

# Encrypted files can change without timestamp or filesize changing - double-check
# Uncomment the following line to backup encrypted data stores
#	rsync -a -c -h --del --ignore-errors --progress /media/Data/crypt/ /media/Backup01/Backups/media/Data/crypt/

