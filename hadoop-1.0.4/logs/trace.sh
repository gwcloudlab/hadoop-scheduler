#!/bin/bash

baseDir=$1
file=$2
if [ -z $file ]
then
        echo $0 [baseDir][file]
        exit 0
fi

Pi_median=0
word_median=0
TeraSort_median=0
sorter_median=0
Iterator_median=0
Classification_median=0

benchmarks="Pi word TeraSort sorter Iterator Classification"
vms="slave00 slave01 slave02 slave1 slave2 slave3 slave4 slave5 slave6 slave7 slave8 slave9 slave10 slave11 slave12 slave13 slave14 slave15 slave16"
dedicatedvms="slave00 slave01 slave02"

<<mark
for benchmark in $benchmarks
do
for dedicatedvm in $dedicatedvms
do
	cat $baseDir/$file | grep $benchmark | grep ExecTime | grep "Type=MAP" | grep $dedicatedvm | awk -F [,=] '{print $16, $20}' >> /home/hadoop/trace/${benchmark}.dedicated
done
done
mark

for benchmark in $benchmarks
do
for dedicatedvm in $dedicatedvms
do
	cat $baseDir/$file | grep "Type=MAP" | grep $benchmark | grep ExecTime | grep $dedicatedvm | awk -F [,=] '{print $16, $20}' >> /home/hadoop/dedicated/${benchmark}_${dedicatedvm}.dedicated
done
done

for benchmark in $benchmarks
do
for dedicatedvm in $dedicatedvms
do
	echo "$benchmark $dedicatedvm"  >> /home/hadoop/dedicated/avgstd.txt
	cat /home/hadoop/dedicated/${benchmark}_${dedicatedvm}.dedicated | awk '{sum+=$1;sumsq+=$1*$1} END {print sum/NR, sqrt(sumsq/NR - (sum/NR)*(sum/NR))}' >> /home/hadoop/dedicated/avgstd.txt
done
done

<<mark
for benchmark in $benchmarks
do
	${benchmark}_median=`sort /home/hadoop/trace/${benchmark}.dedicated | awk -f /home/hadoop/hadoop-scheduler/hadoop-1.0.4/logs/median.awk`
	echo ${benchmark}_median
done
mark

<<mark

Pi_median=`sort /home/hadoop/trace/Pi.dedicated | awk -f /home/hadoop/hadoop-scheduler/hadoop-1.0.4/logs/median.awk`
echo $Pi_median
word_median=`sort /home/hadoop/trace/word.dedicated | awk -f /home/hadoop/hadoop-scheduler/hadoop-1.0.4/logs/median.awk`
echo $word_median
TeraSort_median=`sort /home/hadoop/trace/TeraSort.dedicated | awk -f /home/hadoop/hadoop-scheduler/hadoop-1.0.4/logs/median.awk`
echo $TeraSort_median
sorter_median=`sort /home/hadoop/trace/sorter.dedicated | awk -f /home/hadoop/hadoop-scheduler/hadoop-1.0.4/logs/median.awk`
echo $sorter_median
Iterator_median=`sort /home/hadoop/trace/Iterator.dedicated | awk -f /home/hadoop/hadoop-scheduler/hadoop-1.0.4/logs/median.awk`
echo $Iterator_median
Classification_median=`sort /home/hadoop/trace/Classification.dedicated | awk -f /home/hadoop/hadoop-scheduler/hadoop-1.0.4/logs/median.awk`
echo $Classification_median
mark

<<mark
for benchmark in $benchmarks
do
for vm in $vms
do
	cat $baseDir/$file | grep PredictTime | grep $benchmark | grep ExecTime | grep $vm | awk -F [,=] '{print $16, $20}' >> /home/hadoop/trace/${benchmark}.txt
	#cat $baseDir/$file | grep PredictTime | grep $benchmark | grep ExecTime | grep $vm | awk -F [,=] '{print $16/${benchmark}_median, $20}' >> /home/hadoop/trace/${benchmark}.tmp
	
done

done
mark
