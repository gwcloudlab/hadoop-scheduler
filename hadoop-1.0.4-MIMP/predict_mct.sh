#!/bin/bash

baseDir=$1
file=$2
numOfJobs=$3

if [ -z $numOfJobs ]
then
	echo "Usage:$0 [baseDir] [file] [numOfJobs]"
	exit
fi

for job in $numOfJobs
do
	jobName=`cat $baseDir/$file | grep "201311150329_[0-9]*$job" | grep predictMapPhaseJct | awk -F [,=] '{print $6}'`
	cat $baseDir/$file | grep "201311150329_[0-9]*$job" | grep predictMapPhaseJct | awk -F [,=] '{print $8}' > ${jobName}_201311150329_[0-9]*$job.predicted
	startTime=`cat $baseDir/$file | grep  "201311150329_[0-9]*$job" | grep "Type=MAP" | grep ExecTime | head -n 1 | awk -F [,=] '{print $12}'`
	endTime=`cat $baseDir/$file | grep  "201311150329_[0-9]*$job" | grep "Type=MAP" | grep ExecTime | tail -n 1 | awk -F [,=] '{print $14}'`
	measuredTime=$((($endTime=$startTime)/1000))
	echo $measuredTime > ${jobName}_201311150329_[0-9]*$job.measured
done 
