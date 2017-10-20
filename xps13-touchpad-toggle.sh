#!/bin/bash
# Script to toggle between active and inactive touchpad while typing.

if `xinput -list | grep -q SynPS`; then
    echo ERROR: SynPS/2 device found.
    echo Suspend and resume your laptop, then run this script again.
    notify-send -i /usr/share/icons/suru/devices/scalable/input-touchpad-symbolic.svg "Touchpad Toggle" "ERROR: SynPS/2 device found. Suspend and result your laptop."
    exit 1
fi

if pgrep syndaemon > /dev/null 2>&1; then
    echo Switching to Game Mode.
    notify-send -i /usr/share/icons/suru/devices/scalable/input-touchpad-symbolic.svg "Touchpad Toggle" "Switching to Game Mode."
    killall syndaemon
else
    echo Switching to Work Mode.
    notify-send -i /usr/share/icons/suru/devices/scalable/input-touchpad-symbolic.svg "Touchpad Toggle" "Switching to Work Mode."
    syndaemon -i 0.2 -K -R -d
fi

synclient TouchpadOff=0

exit 0
