#!/usr/bin/env python

# Python CPU bar-graph generator for the Pi Lite
# Written by Gareth Halfacree - http://freelance.halfacree.co.uk
# Requires a Pi Lite, Raspberry Pi, and the psutil and serial libraries.

import serial,psutil,time

s = serial.Serial()
s.baudrate = 9600
s.timeout = 0
s.port = "/dev/ttyAMA0"

try:
    s.open()
except serial.SerialException, e:
    sys.stderr.write("Could not open port %r: %s\n" % (port, e))
    sys.exit(1)
s.write ("$$$ALL,OFF\r")
while True:
    s.write ("$$$SCROLL1\r")
    sysload = psutil.cpu_percent(interval=0)
    sysloadrounded = int(sysload)
    s.write ("$$$B14,%s\r" % sysloadrounded)
    time.sleep(1)
