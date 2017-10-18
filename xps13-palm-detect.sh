#!/bin/bash
# Script to activate palm detection on the Dell XPS 13.

inputDevice = `xinput list | grep DLL075B | cut -d= -f2 | cut -f1`
xinput set-prop $inputDevice "Synaptics Palm Dimensions" 5, 5
xinput set-prop $inputDevice "Synaptics Palm Detection" 1
exit 0
