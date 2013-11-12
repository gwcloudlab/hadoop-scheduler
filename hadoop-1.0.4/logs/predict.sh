#!/bin/bash

file=$1

if [ -z $file ]
then
	cat $file | grep "time=" | awk [=,] '{print $2}' > time_tmp.txt
	cat time_tmp.txt | awk 'BEGIN{last=0; i=1} { if(i != 1) {print $1-last;} last=$1; i++ }'  > time.txt
	cat $file | grep "time=" | awk [=,] '{print $6}' > predict.txt
fi
