echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar pi  -D mapred.job.relative.deadline=$1 $2 1000000
#./bin/hadoop fs -rmr /user/hadoop/PiEstimator_TMP_3_141592654
#time ./bin/hadoop jar hadoop-examples-1.0.4.jar pi  -D mapred.job.relative.deadline=$1 300 1000000
time ./bin/hadoop jar PI.jar org.apache.hadoop.examples.PiEstimator  -D mapred.job.relative.deadline=$1 $2 1000000
