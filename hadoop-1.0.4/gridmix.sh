#!/bin/bash
./bin/hadoop jar hadoop-gridmix-1.0.4.jar org.apache.hadoop.mapred.gridmix.Gridmix -Dgridmix.output.directory=/zhangwei1984/joboutput  -generate 1000m /zhangwei1984/dummy /zhangwei1984/jobtrace.json
