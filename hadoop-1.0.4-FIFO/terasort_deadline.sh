#!/bin/bash

usage()
{
    echo $0 "[deadline], [GB number | all]"
    exit 1
}

if [ -z $2 ] ; then
    usage
fi

<<mark
if [ "$2" == "all" ] ; then
    for((i=1; i<=5; i++)) ; do
        ./bin/hadoop dfs -rmr /zhangwei1984/terasort/output_${i}G

        echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar terasort /zhangwei1984/terasort/input/${i}G_input /zhangwei1984/terasort/output/${i}G_output
        time ./bin/hadoop jar hadoop-examples-1.0.4.jar terasort /zhangwei1984/terasort/input/${i}G_input /zhangwei1984/terasort/output/${i}G_output
    done
else
mark
    suffix=`date +%s`
    echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar terasort -D mapred.job.relative.deadline=$1 /zhangwei1984/terasort/input/${2}G_input /zhangwei1984/terasort/output/${2}G_output_${suffix}
    #time ./bin/hadoop jar hadoop-examples-1.0.4.jar terasort -D mapred.job.relative.deadline=$1 /zhangwei1984/terasort/input/${2}G_input /zhangwei1984/terasort/output/${2}G_output-${suffix}
    time ./bin/hadoop jar TeraSort.jar org.apache.hadoop.examples.terasort.TeraSort -D mapred.job.relative.deadline=$1 /zhangwei1984/terasort/input/${2}G_input /zhangwei1984/terasort/output/${2}G_output_${suffix}
    ./bin/hadoop dfs -rmr /zhangwei1984/terasort/output/${2}G_output_$suffix

#fi
