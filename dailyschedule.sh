#!/bin/bash

# Daily schedule printer! v0.2
# gareth@halfacree.co.uk / https://freelance.halfacree.co.uk
# Depends: Various defaults plus task, figlet,fortune, cowsay, and a 'net
# connection.

# This version expects a custom TaskWarrior report type: "dymo"
# If you don't have one:
# Config Variable         Value
# report.dymo.columns     project,description.count
# report.dymo.description List of due tasks formatted for the Dymo
# report.dymo.filter      due.after:yesterday and due.before:tomorrow and status:pending
# report.dymo.labels      Project,Description
# report.dymo.sort        project+/,entry+

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
curl -s wttr.in/$LOCATION >> "$WEATHERFILE" && \
head -7 "$WEATHERFILE" | tail -5 | sed 's/\x1b\[[0-9;]*m//g' >> "$SCHEDULEFILE"
printf "\n" >> "$SCHEDULEFILE" 

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
