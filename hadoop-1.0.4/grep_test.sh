echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar terasort -D mapred.job.relative.deadline=$1 /zhangwei1984/terasort/input/1G-input /zhangwei1984/terasort/output/1G-output
./bin/hadoop fs -rmr /zhangwei1984/grep/output/1G-output
./bin/hadoop jar hadoop-examples-1.0.4.jar grep -D mapred.job.relative.deadline=$1 /zhangwei1984/wordcount/input/dir_1G /zhangwei1984/grep/output/1G-output 'dfs[a-z.]+' 
