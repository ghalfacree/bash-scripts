#!/usr/bin/env python
# Doorbell server 2 (long story) by Gareth Halfacree <freelance@halfacree.co.uk>

import time, socket, subprocess

bashCommand = "sudo -u blacklaw mocp --pause"
bashCommand2 = "mpg321 /home/blacklaw/bellringing.mp3"
s = socket.socket()
port = 4242
s.bind(('0.0.0.0', port))
s.listen(5)

while True:
    try:
        print 'Listening for connection.'
        c, addr = s.accept()
        print 'Connection accepted from', addr
        print 'Wakey-wakey!.'
        process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
        output = process.communicate()[0]
        process = subprocess.Popen(bashCommand2.split(), stdout=subprocess.PIPE)
        output = process.communicate()[0]
        c.send('Bell rung.\n')
        c.close()

    except KeyboardInterrupt:
        s.close()
