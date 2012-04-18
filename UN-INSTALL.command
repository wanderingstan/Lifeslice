#!/bin/bash

CRON_TEMP='/tmp/cron_temp'
CRON_NEW='/tmp/cron_new'
crontab -l >$CRON_TEMP
awk '$0!~/Lifeslice/ { print $0 }' $CRON_TEMP >$CRON_NEW
cat $CRON_NEW

echo "Lifeslice will no longer take hourly pictures."
echo "No pictures or data have been deleted. To do so, delete the ~/Lifeslice folder entirely."
echo
echo "Thank you for trying Lifeslice."