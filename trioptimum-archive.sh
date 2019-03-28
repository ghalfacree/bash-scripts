#!/bin/bash

rsync -ah --partial --inplace --info=progress2 --delete "/media/Data/Photos/" "/media/blacklaw/1daeaafa-1c0a-46bf-ae1f-4d32ea1d8d9b/Trioptimum/Photos/"
rsync -ah --partial --inplace --info=progress2 --delete "/media/Data/Calibre Library/" "/media/blacklaw/1daeaafa-1c0a-46bf-ae1f-4d32ea1d8d9b/Trioptimum/Calibre Library"
rsync -ah --partial --inplace --info=progress2 --delete "/media/Data/Dropbox/" "/media/blacklaw/1daeaafa-1c0a-46bf-ae1f-4d32ea1d8d9b/Trioptimum/Dropbox/"
rsync -ah --partial --inplace --info=progress2 --delete "/media/Data/Gmail/" "/media/blacklaw/1daeaafa-1c0a-46bf-ae1f-4d32ea1d8d9b/Trioptimum/Gmail/"
rsync -ah --partial --inplace --info=progress2 --delete "/media/Data/My Music/" "/media/blacklaw/1daeaafa-1c0a-46bf-ae1f-4d32ea1d8d9b/Trioptimum/My Music/"
rsync -ah --partial --inplace --info=progress2 --delete "/media/Data/Videos/" "/media/blacklaw/1daeaafa-1c0a-46bf-ae1f-4d32ea1d8d9b/Trioptimum/Videos/"
rsync -ah --partial --inplace --info=progress2 --delete "/media/Data/dos/" "/media/blacklaw/1daeaafa-1c0a-46bf-ae1f-4d32ea1d8d9b/Trioptimum/dos/"
