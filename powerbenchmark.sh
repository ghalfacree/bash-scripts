#!/bin/bash

echo Benchmark begins. CTRL + C to exit.
echo Power Usage > /home/blacklaw/powerbench.csv
while true; do
  pwrstat -status | grep Load | cut -d" " -f2 >> /home/blacklaw/powerbench.csv
  sleep 10
done
