#!/bin/bash
# Script to crop images captured using Gstreamer from a Pi.
# Assumes default overscan settings.

parallel convert {} -crop 1774x901+70+118 {.}.jpg ::: *png
rm *png
