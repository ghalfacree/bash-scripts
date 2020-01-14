#! /bin/bash
# Script to test a CyperPower UPS via pwrstat
# Requires pwrstat to be installed

/usr/sbin/pwrstat -test &> /dev/null
sleep 30

echo UPS self-test completed with result: $(pwrstat -status | grep Result | cut -d' ' -f3-)

exit 0
