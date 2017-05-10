#!/bin/bash
# View HDMI video through Gstreamer on a BlackMagic Intensity Pro

case "$1" in
	1080i)
		echo "Viewing 1080i feed (Mode 12)"
		mode=12;;
	1080p)
		echo "Viewing 1080p feed (Mode 15)"
		mode=15;;
	720p)
		echo "Viewing 720p feed (Mode 18)"
		mode=18;;
	*)
	        echo "No modeline found: defaulting to 1080i (Raspberry
Pi default)"
        	mode=12;;
esac

gst-launch -v decklinkvideosrc mode=$mode connection=1 subdevice=0 ! video/x-raw-yuv ! ffmpegcolorspace ! xvimagesink sync=false
