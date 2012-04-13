#!/bin/bash

# Lifeslice
#
# By Stan James http://wanderingstan.com/
#
# Simple script to capture webcam shot, screenshot, and other data every hour schedule.
# E.g. http://www.meetup.com/Berkeley-QS/photos/6538452/99770812/

# Check if user has been idle too long
# (To we want this? User could be just watching a long movie)
MAX_IDLE_SECONDS="600.0" # 600 seconds = 10 minutes
IDLE_SECONDS=`ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF/1000000000; exit}'`
COMPARE=$(echo "r=0;if($IDLE_SECONDS > $MAX_IDLE_SECONDS)r=1;r" | bc)
if [ $COMPARE = '1' ]
then
	echo "System is idle too long. "$IDLE_SECONDS" seconds, maximum is "$MAX_IDLE_SECONDS". "
	exit
fi

# Create a filename pattern based on current date/time
NOW=$(date "+%Y-%m-%dT%H-%M-%SZ%z")
 
## Lifeslice Data Path ##
BINDIR=$HOME"/Lifeslice/bin" # $(cd "$(dirname "$0")"; pwd) # directory where our scripts and helper applications live (defaults to same dir as this script is in)
DIR=$HOME"/Lifeslice/data" # our destination directory where periodic data will be stored
REPORTDIR=$HOME"/Lifeslice/reports"

# Create our destination directory if it doesn't already exist
# (Might not work because of permissions)
echo `mkdir -p $DIR`

# Take a picture of the screen
# (change extension to .png for higher quality, .jpg for smaller size)
SCREEN=$DIR"/screen_"$NOW".png"
echo `/usr/sbin/screencapture -m -x $SCREEN`

# TODO: Test if a screenshot was taken: if not, screen is probably off, i.e. user is not there

# Take a picture of user
# Using : http://iharder.sourceforge.net/current/macosx/imagesnap/
FACE=$DIR"/face_"$NOW".jpg"
echo `$BINDIR/imagesnap -d "Built-in iSight" $FACE`

# TODO: Use face-detection code (e.g. from SmileFile) to detect if there is a face in front of the screen.

# Remember what app was on top
TOPAPP=$DIR"/current_"$NOW".txt"
echo `/usr/bin/osascript $BINDIR/frontmostapp.scpt  > $TOPAPP`

# If app was a web browser, record current URL
# TODO: Other browsers
# See: http://stackoverflow.com/questions/263741/using-applescript-to-grab-the-url-from-the-frontmost-window-in-web-browsers-the
if grep -q "Google Chrome.app" $TOPAPP
then
	# if found, append URL
	echo `/usr/bin/osascript $BINDIR/current-browser-url.scpt >> $TOPAPP`
fi

# Remember our geographic location
# Using : https://github.com/victor/whereami
LATLON=$DIR"/latlon_"$NOW".txt"
echo `$BINDIR/whereami > $LATLON`

# Re-make our HTML reports
cd $REPORTDIR
echo `php $REPORTDIR/lifeslice-summary.php > $REPORTDIR/lifeslice-summary.html`
echo `php $REPORTDIR/lifeslice-summary-vertical.php > $REPORTDIR/lifeslice-summary-vertical.html`
