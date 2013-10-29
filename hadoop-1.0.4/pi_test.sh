echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar pi  -D mapred.job.relative.deadline=$1 300 1000000
./bin/hadoop fs -rmr /user/hadoop/PiEstimator_TMP_3_141592654
time ./bin/hadoop jar hadoop-examples-1.0.4.jar pi  -D mapred.job.relative.deadline=$1 100 1000000
