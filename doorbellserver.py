#!/usr/bin/env python
# Doorbell server (long story) by Gareth Halfacree <freelance@halfacree.co.uk>

import RPi.GPIO as GPIO
import time, socket

setDelay = 0.05

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

ledPins = [4, 17, 21, 18, 22, 23, 24, 25]

for pin in ledPins:
    GPIO.setup(pin, GPIO.OUT)
    GPIO.output(pin, False)

s = socket.socket()
port = 4242
s.bind(('0.0.0.0', port))
s.listen(5)

while True:
    try:
        print 'Listening for connection.'
        c, addr = s.accept()
        print 'Connection accepted from', addr
        for _ in range(4):
            for pin in ledPins:
                GPIO.output(pin, True)
                time.sleep(setDelay)
            for pin in reversed(ledPins):
                GPIO.output(pin, False)
                time.sleep(setDelay)
        print 'Lit the lights.'
        c.send('Lit the lights.\n')
        c.close()

    except KeyboardInterrupt:
        GPIO.cleanup()
        s.close()
