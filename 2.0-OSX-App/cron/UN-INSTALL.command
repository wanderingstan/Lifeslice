#!/bin/bash

CRON_TEMP='/tmp/cron_temp'
CRON_NEW='/tmp/cron_new'
crontab -l >$CRON_TEMP
awk '$0!~/lifeslice/ { print $0 }' $CRON_TEMP >$CRON_NEW
crontab $CRON_NEW

osascript -e '
	tell application "Finder"
		activate
		set myReply to button returned of (display dialog "The LifeSlice cron-helper was un-installed." )
	end tell
'

