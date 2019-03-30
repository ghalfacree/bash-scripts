#!/bin/bash

# Daily schedule printer! v0.7
# gareth@halfacree.co.uk / https://freelance.halfacree.co.uk
# Depends: Various defaults plus task, figlet, fortune, cowsay,
# gcalcli with oauth configured, and a 'net connection.
# Now with word of the day; requires "wordoftheday.sh" from the
# same place you got this.

# NO LONGER PRINTS BY DEFAULT; OUTPUTS TO STDOUT INSTEAD!
# To actually print, use the --print flag.

# Current formatting optimised for a Dymo 450 using S0929100 name cards.
# Set CUPS to 40cpi/18lpi and a page size of 4.6x7.1cm.

# Tasty variables
LOCATION="bradford"							# Insert your location here
CALENDARS="--calendar=Home --calendar=Work --calendar=Deadlines"	# Calendars to be used by GCalCLI
SCHEDULEFILE="/tmp/dailyschedule.txt"					# Temporary file for the output
WEATHERFILE="/tmp/weather.txt"						# Temporary file for the weather
COWFILE="/tmp/cowfile.txt"						# Temporary file for the cowsay output
PRINTERNAME="LabelWriter-450"						# Name of lp-compatible printer

# The header
date +"%a %F" | figlet -f small.flf > "$SCHEDULEFILE"

# Let's start with the weather and cow...
curl -s wttr.in/$LOCATION?0QT > "$WEATHERFILE"
/usr/games/fortune -a -s | /usr/games/cowsay -W 30 > "$COWFILE"
if grep --quiet Sorry "$WEATHERFILE"; then
    printf "\nWeather service down. :(" > "$WEATHERFILE"
fi
paste "$COWFILE" "$WEATHERFILE" | column -s $'\t' -t >> "$SCHEDULEFILE"
printf "\n" >> "$SCHEDULEFILE"

# Now tasks...
echo -n "TASKS" >> "$SCHEDULEFILE"
task ls >> "$SCHEDULEFILE" || printf "\nNo tasks due!\n" >> "$SCHEDULEFILE"
printf "\n" >> "$SCHEDULEFILE"

# Calendar...
echo "THIS WEEK'S SCHEDULE" >> "$SCHEDULEFILE"
gcalcli --nocolor --lineart ascii --calendar="Holidays in United Kingdom" $CALENDARS calw >> "$SCHEDULEFILE"

# Word of the Day
echo "WORD OF THE DAY" >> "$SCHEDULEFILE"
wordoftheday.sh >> "$SCHEDULEFILE"

# Now wrap and print...
if [ "$1" == "--print" ]; then
    fold -w 72 -s "$SCHEDULEFILE" | lp -d $PRINTERNAME
else
    fold -w 72 -s "$SCHEDULEFILE" | cat "$SCHEDULEFILE"
fi

# Housekeeping
rm "$SCHEDULEFILE" "$WEATHERFILE" "$COWFILE"
exit 0
