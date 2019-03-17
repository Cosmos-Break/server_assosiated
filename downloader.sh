#!/bin/bash
echo "Download starto!"

for file in `ls /root/bt`
do
	#cat /root/bt/$file
	aria2c -T /root/bt/$file
	sleep 20
done
