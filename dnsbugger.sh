#!/bin/bash
# Script to clear various DNS caches.
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root."
	exit 1
fi
/etc/init.d/dns-clean restart
/etc/init.d/dnsmasq restart
/etc/init.d/networking force-reload
