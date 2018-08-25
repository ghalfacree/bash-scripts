#!/bin/bash

# Daily schedule printer! v0.3
# gareth@halfacree.co.uk / https://freelance.halfacree.co.uk
# Depends: Various defaults plus task, figlet,fortune, cowsay, and a 'net
# connection.

# This version expects a custom TaskWarrior report type: "dymo"
# If you don't have one:
# Config Variable         Value
# report.dymo.columns     id,project,description.count
# report.dymo.description List of due tasks formatted for the Dymo
# report.dymo.filter      due.after:yesterday and due.before:tomorrow and status:pending
# report.dymo.labels      ID,Project,Description
# report.dymo.sort        project+/,entry+

# Current formatting optimised for a Dymo 450 using S0929100 name cards.
# Set CUPS to 36cpi/18lpi and a page size of 4.6x7.1cm.

# Tasty variables
LOCATION="bradford"			# Insert your location here
SCHEDULEFILE="/tmp/dailyschedule.txt"	# Temporary file for the output
WEATHERFILE="/tmp/weather.tmp"		# Temporary file for the weather info
PRINTERNAME="LabelWriter-450"		# Name of lp-compatible printer

# The header
date +"%A" | figlet > "$SCHEDULEFILE"
date +"%F" | figlet >> "$SCHEDULEFILE"
printf "\n" >> "$SCHEDULEFILE"

# Let's start with the weather...
echo "Today's Weather" >> "$SCHEDULEFILE"
echo "---------------" >> "$SCHEDULEFILE"
curl -s wttr.in/$LOCATION?1QTn >> "$WEATHERFILE" && \
head -16 "$WEATHERFILE" >> "$SCHEDULEFILE"

# Now tasks...
echo "Tasks Due Today" >> "$SCHEDULEFILE"
echo -n "---------------" >> "$SCHEDULEFILE"
task dymo >> "$SCHEDULEFILE"
printf "\n" >> "$SCHEDULEFILE"

# Now a fortune cookie
echo "What Does the Cow Say?" >> "$SCHEDULEFILE"
echo "----------------------" >> "$SCHEDULEFILE"
fortune -a -s | cowsay >> "$SCHEDULEFILE"

# Now wrap and print...
fold -w 65 -s "$SCHEDULEFILE" | lp -d $PRINTERNAME

# Housekeeping
rm "$WEATHERFILE" "$SCHEDULEFILE"
exit 0
