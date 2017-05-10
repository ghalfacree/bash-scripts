#!/bin/bash
# View HDMI video through Gstreamer on a BlackMagic Intensity Pro

case "$1" in
	1080i)
		echo "Viewing 1080i feed (Mode 12)"
		mode=13;;
	1080p)
		echo "Viewing 1080p feed (Mode 15)"
		mode=10;;
	720p)
		echo "Viewing 720p feed (Mode 18)"
		mode=19;;
	*)
	        echo "No modeline found: defaulting to 1080i (Raspberry
Pi default)"
        	mode=13;;
esac

gst-launch-1.0 -v decklinkvideosrc mode=$mode ! videoconvert ! xvimagesink
