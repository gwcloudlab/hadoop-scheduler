#!/bin/bash

usage()
{
    echo $0 "[deadline], [GB number | all]"
    exit 1
}

if [ -z $1 ] ; then
    usage
fi

<<mark
if [ "$2" == "all" ] ; then
    for((i=1; i<=5; i++)) ; do
        ./bin/hadoop dfs -rmr /zhangwei1984/wordcount/output_${i}G

        echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar wordcount /zhangwei1984/wordcount/input/${i}G_input /zhangwei1984/wordcount/output/${i}G_output
        time ./bin/hadoop jar hadoop-examples-1.0.4.jar wordcount /zhangwei1984/wordcount/input/${i}G_input /zhangwei1984/wordcount/output/${i}G_output
    done
else
mark
    suffix=`date +%s`
    echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar wordcount -D mapred.job.relative.deadline=$1 /zhangwei1984/wordcount/input/${2}G_input /zhangwei1984/wordcount/output/${2}G_output_$suffix
    time ./bin/hadoop jar hadoop-examples-1.0.4.jar wordcount -D mapred.job.relative.deadline=$1 /zhangwei1984/wordcount/input/${2}G_input /zhangwei1984/wordcount/output/${2}G_output_`date +%s`
    ./bin/hadoop dfs -rmr /zhangwei1984/wordcount/output/${2}G_output_$suffix

#fi
