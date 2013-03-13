#!/bin/bash
# Check the number of failed logins in auth.log
# If you're running anything other than OpenSSH 1.6, this will likely need changing
grep invalid /var/log/auth.log | cut -d' ' -f9 | sort | uniq -c
