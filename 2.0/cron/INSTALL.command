#!/bin/bash

# Lifeslice Helper Cron Job
#
# By Stan James http://wanderingstan.com/
#

# Needed because a script launched as .command seems to start
# in the user's home directory, and not the directory where 
# the script is.
BASEDIR=$(cd "$(dirname "$0")"; pwd)
cd $BASEDIR

# #
# # Copy files to the right place, if they aren't already there
# #
BINDIR=$BASEDIR


# 
# Set up cron job
#
if crontab -l | grep -q "$BINDIR"
then
	echo "Your cron job is already set up."
	osascript -e '
	tell application "Finder"
		activate
		set myReply to button returned of (display dialog "The LifeSlice cron-helper is already installed." )
	end tell
	'

else	
	# We check a few minutes *after* the hour, to give time for the app to run. 
	echo -e "`crontab -l`\n# lifeslice: webcam and screenshots every hour\n3 0 * * * python $BINDIR/lifeslice-helper.py >/dev/null 2>&1" | crontab -
	echo
	echo "A cron job has just been created to run every hour."
	osascript -e '
	tell application "Finder"
		activate
		set myReply to button returned of (display dialog "The LifeSlice cron-helper is now installed. It will notify you if LifeSlice stops running." )
	end tell
	'
fi

# # run script
# python $BINDIR/lifeslice-helper.py
