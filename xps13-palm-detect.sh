#!/bin/bash
# Script to activate palm detection on the Dell XPS 13.

if `xinput -list | grep -q SynPS`; then
    echo ERROR: SynPS/2 device found.
    echo Suspend and resume your laptop, then run this script again.
    exit 1
fi

echo Killing currently-running syndaemon...
killall syndaemon > /dev/null 2>&1

echo Enabling palm detection...
xinput set-prop `xinput list | grep DLL075B | cut -d= -f2 | cut -f1` "Synaptics Palm Dimensions" 5, 5
xinput set-prop `xinput list | grep DLL075B | cut -d= -f2 | cut -f1` "Synaptics Palm Detection" 1
echo Enabling three-finger-tap for middle click...
synclient TapButton3=2

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
