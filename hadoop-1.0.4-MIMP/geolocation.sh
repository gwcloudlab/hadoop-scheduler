#!/bin/bash

bin/hadoop dfs -rmr /jinho/geolocation/output

echo time bin/hadoop jar hadoop-download-examples.jar com.hadoop.examples.geolocation.GeoLocationJob /jinho/geolocation/input /jinho/geolocation/output
time bin/hadoop jar hadoop-download-examples.jar com.hadoop.examples.geolocation.GeoLocationJob /jinho/geolocation/input /jinho/geolocation/output
