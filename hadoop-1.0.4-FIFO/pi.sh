#!/bin/bash

# 100 maps / 1G samples
echo time ./bin/hadoop jar hadoop-examples-1.0.4.jar pi 100 1000000
time ./bin/hadoop jar hadoop-examples-1.0.4.jar pi 100 1000000
