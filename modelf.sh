#!/bin/bash

# Key remapping for the IBM Model F PC/AT

setxkbmap -option caps:super
xmodmap -e "keycode 49 = backslash bar bar bar bar"
