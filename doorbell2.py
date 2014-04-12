#!/usr/bin/env python

import RPi.GPIO as GPIO
from twython import Twython
import time, datetime, socket

buttonPin = 4 
relayPin = 25
screenName = 'ghalfacree'

api_token = ''
api_secret = ''
access_token = ''
access_token_secret = ''

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(buttonPin, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
GPIO.setup(relayPin, GPIO.OUT)
GPIO.output(relayPin, True)

twitter = Twython(api_token, api_secret, access_token, access_token_secret)

while True:
    try:
        print 'Waiting for doorbell...'
        GPIO.wait_for_edge(buttonPin, GPIO.RISING)
        print 'There\'s somebody at the door, there\'s somebody at the door!'
        print 'Triggering office LED server...'
        try:
            s = socket.socket()
            s.settimeout(1)
            s.connect(('192.168.0.20', 4242))
            s.close()
            print 'LED server notified.'
        except socket.error:
            print 'Network error, LED server offline.'
        print 'Ringing original doorbell...'
        GPIO.output(relayPin, False)
        time.sleep(0.5)
        GPIO.output(relayPin, True)
        print 'Doorbell sounding.'
        print 'Alerting Trioptimum...'
        try:
            s = socket.socket()
            s.settimeout(1)
            s.connect(('192.168.0.50', 4242))
            s.close()
            print 'Trioptimum notified.'
        except socket.error:
            print 'Network error, Trioptimum offline.'
        print 'Sending Twitter DM...'
        twitter.send_direct_message(screen_name=screenName, text='DING-DONG at %s' %datetime.datetime.now())
        print 'Message sent. All done!'
        print

    except KeyboardInterrupt:
        GPIO.cleanup()
