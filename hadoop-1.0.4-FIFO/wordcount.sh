#!/bin/bash

usage()
{
    echo $0 "<GB number | all>"
    exit 1
}

if [ -z $1 ] ; then
    usage
fi

if [ "$1" == "all" ] ; then
    for((i=1; i<=5; i++)) ; do
        ./bin/hadoop dfs -rmr /jinho/wordcount/output_${i}G

        echo time ./bin/hadoop jar wordcount.jar WordCount /jinho/wordcount/input/dir_${i}G /jinho/wordcount/output_${i}G
        time ./bin/hadoop jar wordcount.jar WordCount /jinho/wordcount/input/dir_${i}G /jinho/wordcount/output_${i}G
    done
else
    echo time ./bin/hadoop jar wordcount.jar WordCount /jinho/wordcount/input/dir_${1}G /jinho/wordcount/output_${1}G
    ./bin/hadoop dfs -rmr /zhangwei1984/wordcount/output/output_${1}G
    time ./bin/hadoop jar hadoop-examples-1.0.4.jar wordcount /zhangwei1984/wordcount/input/dir_${1}G /zhangwei1984/wordcount/output/output_${1}G
fi
