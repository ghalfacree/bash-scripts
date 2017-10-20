#!/bin/bash
# Script to activate palm detection on the Dell XPS 13.

echo Killing currently-running syndaemon...
killall syndaemon > /dev/null 2>&1
echo Enabling palm detection...
xinput set-prop `xinput list | grep DLL075B | cut -d= -f2 | cut -f1` "Synaptics Palm Dimensions" 5, 5
xinput set-prop `xinput list | grep DLL075B | cut -d= -f2 | cut -f1` "Synaptics Palm Detection" 1
if [ "$1" == "--type-disable" ] || [ "$1" == "-td" ]; then
    echo Trackpad disabled while typing.
    syndaemon -i 0.2 -K -R -d
    synclient TouchpadOff=0
else
    echo Trackpad enabled while typing.
    synclient TouchpadOff=0
fi
echo Done!
exit 0
