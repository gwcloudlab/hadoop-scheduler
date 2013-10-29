#!/bin/bash

usage()
{
    echo $0 "deadline, <GB number | all>"
    exit 1
}

if [ -z $2 ] ; then
    usage
fi

if [ "$2" == "all" ] ; then
    for((i=1; i<=5; i++)) ; do
        ./bin/hadoop dfs -rmr /zhangwei1984/grep/output_${i}G

        echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar grep /zhangwei1984/grep/input/${i}G_input /zhangwei1984/grep/output/${i}G_output
        time ./bin/hadoop jar hadoop-examples-1.0.4.jar grep /zhangwei1984/grep/input/${i}G_input /zhangwei1984/grep/output/${i}G_output 'dfs[a-z.]+'
    done
else
    echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar grep -D mapred.job.relative.deadline=$1 /zhangwei1984/grep/input/${2}G_input /zhangwei1984/grep/output/${2}G_output
    ./bin/hadoop dfs -rmr /zhangwei1984/grep/output/${2}G_output
    time ./bin/hadoop jar hadoop-examples-1.0.4.jar grep -D mapred.job.relative.deadline=$1 /zhangwei1984/grep/input/${2}G_input /zhangwei1984/grep/output/${2}G_output 'dfs[a-z.]+'
    #time ./bin/hadoop jar grep.jar org.apache.hadoop.examples.Grep grep -D mapred.job.relative.deadline=$1 /zhangwei1984/grep/input/${2}G_input /zhangwei1984/grep/output/${2}G_output 'dfs[a-z.]+'

fi
