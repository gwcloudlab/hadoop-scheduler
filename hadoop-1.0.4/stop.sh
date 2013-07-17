#!/bin/bash

ssh hadoop@slave /home/hadoop/hadoop-1.0.4/bin/stop-mapred.sh
./bin/stop-dfs.sh
