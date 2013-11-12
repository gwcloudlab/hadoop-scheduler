#!/bin/bash

xentop -b -d 1 -i 6 > test.txt
#mastertest=`cat test.txt | grep web-2 | tail -n 5 | awk '{sum+=$4} END {print sum/NR}'`
mastertest=20
echo -e "mastertest\t$mastertest" > monitor.txt

