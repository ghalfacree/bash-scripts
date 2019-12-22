#!/usr/bin/env python
# Doorbell server (long story) by Gareth Halfacree <freelance@halfacree.co.uk>

import urllib2
import RPi.GPIO as GPIO
from twython import Twython
import time, datetime, socket, urllib
from smbus import SMBus

setDelay = 0.025

CMD_ENABLE_OUTPUT = 0x00
CMD_ENABLE_LEDS = 0x13
CMD_SET_PWM_VALUES = 0x01
CMD_UPDATE = 0x16

class PiGlow:
	i2c_addr = 0x54 # fixed i2c address of SN3218 ic
	bus = None

	def __init__(self, i2c_bus=1):
		self.bus = SMBus(i2c_bus)

        # first we tell the SN3218 to enable output (turn on)
		self.write_i2c(CMD_ENABLE_OUTPUT, 0x01)

        # then we ask it to enable each bank of LEDs (0-5, 6-11, and 12-17)
		self.write_i2c(CMD_ENABLE_LEDS, [0xFF, 0xFF, 0xFF])

	def update_leds(self, values):
		print "update pwm"
		self.write_i2c(CMD_SET_PWM_VALUES, values)
		self.write_i2c(CMD_UPDATE, 0xFF)

	# a helper that writes the given value or list of values to the SN3218 IC
	# over the i2c protocol
	def write_i2c(self, reg_addr, value):
        # if a single value is provided then wrap it in a list so we can treat
        # all writes in teh same way
		if not isinstance(value, list):
			value = [value];

        # write the data to the SN3218
		self.bus.write_i2c_block_data(self.i2c_addr, reg_addr, value)

# a list of 18 values between 0 - 255 that represent each LED on the PiGlow.
# to change the LEDs we set the values in this array and then pass it to the
# update_leds() function to actually update the LDEs
values = [0x01,0x02,0x04,0x08,0x10,0x18,0x20,0x30,0x40,0x50,0x60,0x70,0x80,0x90,0xA0,0xC0,0xE0,0xFF]

# create an instance of our PiGlow class and tell it that "1" is the I2C bus
# index (should be 0 for old old old Pis)
piglow = PiGlow(0)

screenName = 'XXXXXX'

api_token = 'XXXXXXX'
api_secret = 'XXXXXXXXX'
access_token = 'XXXXXXX'
access_token_secret = 'XXXXXXX'

#def sendSMS(to, message, hash):
#    params = urllib.urlencode({'to': to, 'message': message, 'hash': hash})
#    f = urllib.urlopen('http://www.smspi.co.uk/send/', params)
#    return (f.read(), f.code)

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

ledPins = [4, 17, 21, 18, 22, 23, 24, 25]

twitter = Twython(api_token, api_secret, access_token, access_token_secret)

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
	print 'Alerting Trioptimum...'
        try:
            ss = socket.socket()
            ss.settimeout(1)
            ss.connect(('192.168.0.50', 4242))
            ss.close()
        except socket.error:
            print 'Network error, Trioptimum offline.'
        print 'Notifying IFTTT...'
        urllib2.urlopen('https://maker.ifttt.com/trigger/doorbell_rang/with/key/XXXXXXXXXXXX')
        print 'IFTTT notified.'
        for _ in range(64):
            values.append(values.pop(0))
            time.sleep(setDelay)
            piglow.update_leds(values)
        values = [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00]
        piglow.update_leds(values)
        values = [0x01,0x02,0x04,0x08,0x10,0x18,0x20,0x30,0x40,0x50,0x60,0x70,0x80,0x90,0xA0,0xC0,0xE0,0xFF]
        print 'Lit the lights.'
        c.send('Lit the lights.\n')
        c.close()
#        print 'Trioptimum alerted. Sending Twitter DM...'
#        twitter.send_direct_message(screen_name=screenName, text='DING-DONG at %s' %datetime.datetime.today().strftime("%A %d %B %Y, %R"))
#        print 'Sending SMS via SMSPi.co.uk...'
#        resp, code  = sendSMS('XXXXXXXXXXX', 'DING-DONG at %s' %datetime.datetime.today().strftime("%A %d %B %Y, %R"), 'XXXXXXXXXX')
#        print 'Message sent. All done!'
#	print
    except KeyboardInterrupt:
        values = [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00]
        piglow.update_leds(values)
        GPIO.cleanup()
        s.close()
