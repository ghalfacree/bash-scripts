#!/bin/bash
# Script to activate palm detection on the Dell XPS 13.

xinput set-prop `xinput list | grep DLL075B | cut -d= -f2 | cut -f1` "Synaptics Palm Dimensions" 5, 5
xinput set-prop `xinput list | grep DLL075B | cut -d= -f2 | cut -f1` "Synaptics Palm Detection" 1
syndaemon -i 0.5 -K -R -d
exit 0
