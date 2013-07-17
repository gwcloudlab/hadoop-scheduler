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
        ./bin/hadoop dfs -rmr /zhangwei1984/terasort/output/${i}G-output

        echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar terasort /zhangwei1984/terasort/input/${i}G-input /zhangwei1984/terasort/output/${i}G-output
        time ./bin/hadoop jar hadoop-examples-1.0.4.jar terasort /zhangwei1984/terasort/input/${i}G-input /zhangwei1984/terasort/output/${i}G-output

    done
else
    echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar terasort /zhangwei1984/terasort/input/${1}G-input /zhangwei1984/terasort/output/${1}G-output
    ./bin/hadoop dfs -rmr /zhangwei1984/terasort/output/${1}G-output
    time ./bin/hadoop jar hadoop-examples-1.0.4.jar terasort /zhangwei1984/terasort/input/${1}G-input /zhangwei1984/terasort/output/${1}G-output
fi
