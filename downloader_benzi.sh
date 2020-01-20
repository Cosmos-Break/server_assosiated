#!/bin/bash
echo "Download starto!"

for file in `ls /root/bt`
do
	#cat /root/bt/$file
	nohup aria2c -T /root/bt/$file >/dev/null 2>&1 &
done
