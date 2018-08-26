#!/bin/bash

# Daily schedule printer! v0.4
# gareth@halfacree.co.uk / https://freelance.halfacree.co.uk
# Depends: Various defaults plus task, figlet, fortune, cowsay,
# gcalcli with oauth configured, and a 'net connection.

# This version expects a custom TaskWarrior report type: "dymo"
# If you don't have one:
# Config Variable         Value
# report.dymo.columns     id,project,description.count
# report.dymo.description List of due tasks formatted for the Dymo
# report.dymo.filter      due.after:yesterday and due.before:tomorrow and status:pending
# report.dymo.labels      ID,Project,Description
# report.dymo.sort        project+/,entry+

# Current formatting optimised for a Dymo 450 using S0929100 name cards.
# Set CUPS to 40cpi/18lpi and a page size of 4.6x7.1cm.

# Tasty variables
LOCATION="bradford"							# Insert your location here
CALENDARS="--calendar=Home --calendar=Work --calendar=Deadlines"	# Calendars to be used by GCalCLI
SCHEDULEFILE="/tmp/dailyschedule.txt"					# Temporary file for the output
PRINTERNAME="LabelWriter-450"						# Name of lp-compatible printer

# The header
date +"%A %F" | figlet -f small.flf > "$SCHEDULEFILE"
printf "\n" >> "$SCHEDULEFILE"

# Let's start with the weather...
echo "Today's Weather" >> "$SCHEDULEFILE"
echo "---------------" >> "$SCHEDULEFILE"
curl -s wttr.in/$LOCATION?0QT >> "$SCHEDULEFILE"
printf "\n" >> "$SCHEDULEFILE"

# Now tasks...
echo "Tasks Due Today" >> "$SCHEDULEFILE"
echo -n "---------------" >> "$SCHEDULEFILE"
task dymo >> "$SCHEDULEFILE"
printf "\n" >> "$SCHEDULEFILE"

# Calendar...
echo "This Week's Schedule" >> "$SCHEDULEFILE"
echo -n "--------------------" >> "$SCHEDULEFILE"
gcalcli calw 1 --calendar="Holidays in United Kingdom" $CALENDARS --nocolor --nolineart -w 9 >> "$SCHEDULEFILE"

# Now a fortune cookie
echo "What Does the Cow Say?" >> "$SCHEDULEFILE"
echo "----------------------" >> "$SCHEDULEFILE"
fortune -a -s | cowsay >> "$SCHEDULEFILE"

# Now wrap and print...
fold -w 72 -s "$SCHEDULEFILE" | lp -d $PRINTERNAME

# Housekeeping
rm "$SCHEDULEFILE"
exit 0
