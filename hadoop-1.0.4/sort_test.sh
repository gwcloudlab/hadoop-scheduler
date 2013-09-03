echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar pi  -D mapred.job.relative.deadline=$1 100 1000000
./bin/hadoop fs -rmr /zhangwei1984/sort/output/sorted
./bin/hadoop jar hadoop-examples-1.0.4.jar sort  -D mapred.job.relative.deadline=$1 /zhangwei1984/sort/input/rand /zhangwei1984/wordcount/output/sorted
