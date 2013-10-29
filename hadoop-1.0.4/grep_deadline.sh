#!/bin/bash

usage()
{
    echo $0 "[grep-search deadline], [GB number | all], [grep-sort deadline]"
    exit 1
}

if [ -z $2 ] ; then
    usage
fi

<<mark
if [ "$2" == "all" ] ; then
    for((i=1; i<=5; i++)) ; do
        ./bin/hadoop dfs -rmr /zhangwei1984/grep/output_${i}G

        echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar grep /zhangwei1984/grep/input/${i}G_input /zhangwei1984/grep/output/${i}G_output
        time ./bin/hadoop jar hadoop-examples-1.0.4.jar grep /zhangwei1984/grep/input/${i}G_input /zhangwei1984/grep/output/${i}G_output 'dfs[a-z.]+'
    done
else
mark
    suffix=`date +%s`
    echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar grep -D mapred.job.relative.deadline=$1 /zhangwei1984/grep/input/${2}G_input /zhangwei1984/grep/output/${2}G_output
    #time ./bin/hadoop jar grep.jar org.apache.hadoop.examples.Grep -D mapred.job.relative.deadline=$1 /zhangwei1984/sort/input/${2}G_input /zhangwei1984/grep/output/${2}G_output_$suffix 'dfs[a-z.]+' $3
    time ./bin/hadoop jar grep-V2.jar org.apache.hadoop.examples.Grep -D mapred.job.relative.deadline=$1 /zhangwei1984/sort/input/${2}G_input /zhangwei1984/grep/output/${2}G_output_$suffix 'dfs[a-z.]+' $3
    ./bin/hadoop dfs -rmr /zhangwei1984/grep/output/${2}G_output_${suffix}

#fi
