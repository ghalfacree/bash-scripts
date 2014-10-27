#!/bin/bash
# Sick of typing this out by hand each time!
if [ "$1" == "" ]; then
	echo No command name found - exiting
	exit 1
fi
ps axufw | grep $1 | grep -v grep | grep -v psfind.sh
