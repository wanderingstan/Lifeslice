#!/bin/bash

# Lifeslice
#
# By Stan James http://wanderingstan.com/
#
# Update LifeSlice to the latest version from GitHub

echo
echo "==========================================================="
echo
echo "  Updating Lifeslice to the latest version."
echo "  Check for the latest info at https://github.com/wanderingstan/Lifeslice"
echo
echo "==========================================================="

# download latest
wget --no-check-certificate https://github.com/downloads/wanderingstan/Lifeslice/lifeslice_LATEST.zip

# unzip it
unzip -d /tmp/bob lifeslice_LATEST.zip 

# run the local update script just to be sure
./bin/local_update.sh

echo
echo "==========================================================="
echo
echo "  Updating complete."
echo
echo "==========================================================="
read dummy
