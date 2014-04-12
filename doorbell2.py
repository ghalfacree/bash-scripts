#!/usr/bin/env python

import RPi.GPIO as GPIO
from twython import Twython
import time, datetime, socket

buttonPin = 23
relayPin = 17
screenName = 'ghalfacree'

api_token = ''
api_secret = ''
access_token = ''
access_token_secret = ''

GPIO.setmode(GPIO.BCM)
GPIO.setup(buttonPin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(relayPin, GPIO.OUT)
GPIO.outout(relayPin, False)

s = socket.socket()

twitter = Twython(api_token, api_secret, access_token, access_token_secret)

while True:
    try:
        print 'Waiting for doorbell...'
        GPIO.wait_for_edge(buttonPin, GPIO.FALLING)
        print 'There\'s somebody at the door, there\'s somebody at the door!'
        print 'Triggering office LED server...'
        s.connect(('192.168.0.20', 4242))
        s.close()
        print 'LED server notified. Ringing original doorbell...'
        GPIO.output(relayPin, True)
        time.sleep(0.5)
        GPIO.output(relayPin, False)
        print 'Doorbell sounding. Sending Twitter DM...'
        twitter.send_direct_message(screen_name=screenName, text='DING-DONG at %s' %datetime.datetime.now())
        print 'Message sent. All done!'

    except KeyboardInterrupt:
        GPIO.cleanup()
