#!/bin/bash

benchmarks="Pi word TeraSort sorter grep-search grep-sort Iterator Classification"

for benchmark in $benchmarks
do
	echo "Measured	Predicted	PredictedError" > ${benchmark}_measured_predicted.txt
	cat hadoop-hadoop-jobtracker-master.out | grep ExecTime | grep $benchmark | grep "Type=MAP" | awk -F [,=] '{if ($16>=$18) {print $16, $18, $16-$18} else {print $16,$18, $18-$16}}' >> ${benchmark}_measured_predicted.txt
	cat ${benchmark}_measured_predicted.txt | awk '{if ($1>=$2) {sum+=$1-$2} else {sum+=$2-$1}}END{print sum/NR}' >> error.txt

done
