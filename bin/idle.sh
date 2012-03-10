#!/bin/bash
IDLE=`ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF/1000000000; exit}'`
echo $IDLE

exit

if [ `echo "if($IDLE>5.0)r=1;r"|bc`="0" ]
then
	echo "yoyoyo"
fi