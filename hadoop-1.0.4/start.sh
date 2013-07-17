#!/bin/bash

ssh hadoop@slave /home/hadoop/hadoop-1.0.4/bin/start-mapred.sh
./bin/start-dfs.sh
