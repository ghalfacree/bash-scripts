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
GPIO.output(relayPin, False)

twitter = Twython(api_token, api_secret, access_token, access_token_secret)

def buttonPushed():
    print 'GPIO activity detected, was the button pushed?'
    time.sleep(0.01)
    if GPIO.input(buttonPin) != GPIO.HIGH:
        print 'False alarm.'
        return
    print 'There\'s somebody at the door, there\'s somebody at the door!'
    print 'Triggering office LED server...'
    try:
        s = socket.socket()
        s.settimeout(1)
        s.connect(('192.168.0.20', 4242))
        s.close()
    except socket.error:
        print 'Network error, LED server offline.'
    print 'LED server notified. Ringing original doorbell...'
    GPIO.output(relayPin, True)
    time.sleep(0.5)
    GPIO.output(relayPin, False)
    print 'Doorbell sounding, alerting Trioptimum...'
    try:
        s = socket.socket()
        s.settimeout(1)
        s.connect(('192.168.0.50', 4242))
        s.close()
    except socket.error:
        print 'Network error, Trioptimum offline.'
    print 'Trioptimum alerted. Sending Twitter DM...'
    #twitter.send_direct_message(screen_name=screenName, text='DING-DONG at %s' %datetime.datetime.now())
    twitter.send_direct_message(screen_name=screenName, text='DING-DONG at %s' %datetime.datetime.today().strftime("%A %d %B %Y, %R"))
    print 'Message sent. All done!'

while True:
    try:
        print 'Waiting for doorbell...'
        GPIO.wait_for_edge(buttonPin, GPIO.RISING)
        buttonPushed()
        print

    except KeyboardInterrupt:
        GPIO.cleanup()
