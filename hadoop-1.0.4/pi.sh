#!/bin/bash

# 100 maps / 1G samples
echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar pi 2000 1000000
./bin/hadoop fs -rmr /user/hadoop/PiEstimator_TMP_3_141592654
time ./bin/hadoop jar hadoop-examples-1.0.4.jar pi 2000 1000000
