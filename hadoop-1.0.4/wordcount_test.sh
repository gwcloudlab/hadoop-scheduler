echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar pi  -D mapred.job.relative.deadline=$1 100 1000000
./bin/hadoop fs -rmr /zhangwei1984/wordcount/output/output_1G
./bin/hadoop jar wordcount-zhangwei1984.jar WordCount  -D mapred.job.relative.deadline=$1 /zhangwei1984/wordcount/input/dir_1G /zhangwei1984/wordcount/output/output_1G
