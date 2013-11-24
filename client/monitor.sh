#!/bin/bash

interval=5

xentop -b -d 1 -i $interval > test.txt
slave1cpu=`cat test.txt | grep "wb-171" | tail -n $(($interval-1)) | awk '{sum+=$4} END {print sum/NR}'`
slave2cpu=`cat test.txt | grep "wb-172" | tail -n $(($interval-1)) | awk '{sum+=$4} END {print sum/NR}'`
slave1disk=0
#slave3disk=`cat test.txt | grep slave3| tail -n $(($interval-1)) | awk 'BEGIN{last=0; i=1} { if(i != 1) {print $17+$18-last} last=$17+$18; i++ }' | tail -n $(($interval-2)) | awk '{sum+=$1} END {print sum/NR}'`
slave2disk=0
echo -e "slave1\t${slave1cpu}\t${slave1disk}" > monitor.txt
echo -e "slave2\t${slave2cpu}\t${slave2disk}" >> monitor.txt

