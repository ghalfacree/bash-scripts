#!/usr/bin/env python
# Tweeting doorbell for Raspberry Pi.
# Written by Gareth Halfacree <freelance@halfacree.co.uk>


import RPi.GPIO as GPIO
from twython import Twython
import datetime

api_token = 'InsertTokenHere'
api_secret = 'InsertSecretHere'
access_token = 'InsertOAuthTokenHere'
access_token_secret = 'InsertOAuthSecretHere'

GPIO.setmode(GPIO.BCM)
GPIO.setup(23, GPIO.IN, pull_up_down=GPIO.PUD_UP)

twitter = Twython(api_token, api_secret, access_token, access_token_secret)

while True:
    try:
        print "Waiting for doorbell..."
        GPIO.wait_for_edge(23, GPIO.FALLING)
        print "Doorbell detected, sending direct message."
        twitter.send_direct_message(screen_name="ghalfacree", text="DING-DONG at %s" %datetime.datetime.now())

    except KeyboardInterrupt:
        GPIO.cleanup()
