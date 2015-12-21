#!/bin/bash

mkdir /tmp/drivestats

for i in a b c d; do
  echo /dev/sd$i status:
  smartctl -a /dev/sd$i > '/tmp/drivestats/sd'$i'status.txt'
  grep "Model" '/tmp/drivestats/sd'$i'status.txt'
  grep Reallocated '/tmp/drivestats/sd'$i'status.txt'
  grep Pending '/tmp/drivestats/sd'$i'status.txt'
  grep Temperature '/tmp/drivestats/sd'$i'status.txt'
  grep self-assessment '/tmp/drivestats/sd'$i'status.txt'
  echo ""
done

#echo ""
#echo Full SMART reports follow...

for i in a b c d; do
#  cat '/tmp/drivestats/sd'$i'status.txt'
#  echo ""
  rm '/tmp/drivestats/sd'$i'status.txt'
done

rmdir /tmp/drivestats
exit
