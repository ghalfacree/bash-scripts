#!/bin/bash

# Key remapping for the IBM Model F PC/AT

#setxkbmap -option caps:super
xmodmap -e "keycode 49 = backslash bar bar bar bar"
xmodmap -e "keycode 66 = Super_L Caps_Lock NoSymbol Caps_Lock"
