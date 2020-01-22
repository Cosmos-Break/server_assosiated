#!/bin/bash
echo "Download starto!"

count=0
for file in `ls /root/bt`
do
	let count++
	#cat /root/bt/$file
	if [ $(($count%100)) = '0' ];then
	sleep 86400
	fi
	sleep 0.5
	nohup aria2c -T /root/bt/$file >/dev/null 2>&1 &
done
