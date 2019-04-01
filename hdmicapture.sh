#!/bin/bash
# View HDMI video through Gstreamer on a BlackMagic Intensity Pro

case "$1" in
	1080i)
		echo "Viewing 1080i feed (Mode 13)"
		mode=13;;
	1080p)
		echo "Viewing 1080p feed (Mode 10)"
		mode=10;;
	720p)
		echo "Viewing 720p feed (Mode 19)"
		mode=19;;
	*)
	        echo "No modeline found: defaulting to 1080i (Raspberry
Pi default)"
        	mode=13;;
esac

#gst-launch-1.0 -v decklinkvideosrc mode=$mode ! videoconvert ! xvimagesink
gst-launch-1.0 decklinkvideosrc mode=$i ! videoconvert ! xvimagesink decklinkaudiosrc typefind=true do-timestamp=true alignment-threshold=100 ! audioconvert ! autoaudiosink sync=false
