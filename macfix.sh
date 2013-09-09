#!/bin/bash
# Fix for stupid mDNS resolution breaking in Mac OS X. Stupid thing.
ifconfig en0 down
ifconfig en0 up
echo It may be fixed. Or possibly not. Good luck!
