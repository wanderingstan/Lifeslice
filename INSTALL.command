# Lifeslice
#
# By Stan James http://wanderingstan.com/
#
# Simple script to capture webcam shot, screenshot, and other data every hour schedule.
# E.g. http://www.meetup.com/Berkeley-QS/photos/6538452/99770812/

echo
echo "==========================================================="
echo
echo "    Thank you for trying Lifeslice"
echo
echo "==========================================================="

# Needed because a script launched as .command seems to start
# in the user's home directory, and not the directory where 
# the script is.
BASEDIR=$(dirname $0)
cd $BASEDIR

#
# Copy files to the right place, if they aren't already there
#
BINDIR=$HOME"/Lifeslice/bin"
DIR=$HOME"/Lifeslice" # our destination directory where periodic data will be stored
REPORTDIR=$HOME"/Lifeslice/reports"

if [ "${PWD##*/}" != "Lifeslice" ]
then
	echo "Sorry, this script needs to be in a folder named 'Lifeslice'"
	echo " in order to be installed."
	echo ""
	echo "Currently it is named "${PWD##*/}
	exit
fi
if [ $(pwd) != $HOME"/Lifeslice" ]
then
	echo "Copying Lifeslice directory to user directory."
 	cp -R . $HOME"/Lifeslice"
fi

# 
# Set up cron job
#
if crontab -l | grep -q "$BINDIR"
then
	echo "Your cron job is already set up."
else	
	echo -e "`crontab -l`\n# Lifeslice: webcam and screenshots every hour\n0 * * * * $BINDIR/lifeslice-run.command >/dev/null 2>&1" | crontab -
	echo
	echo "A cron job has just been created to run every hour."
fi


echo
echo "Raw webcam shots, screen shots, geo coordinates, and "
echo "current applications will be saved to:"
echo "$DIR"
echo
echo "You can view your Lifeslice web report at:"
echo "file://$REPORTDIR/lifeslice-summary.html"
echo
echo "==========================================================="
echo
echo "Press ENTER to take first picture, and view your first web report."
echo
echo "When asked to allow 'whereami' to know your location, answer 'Yes' and check 'Don't ask again'."
echo
read dummy

# run script
$BINDIR/lifeslice-run.command

# open report
open $REPORTDIR"/lifeslice-summary.html"