#!/bin/bash

bin/hadoop dfs -rmr /jinho/anagram/output

#echo time bin/hadoop jar hadoop-download-examples.jar com.hadoop.examples.anagrams.AnagramJob /jinho/wordcount/input/dir_5G /jinho/anagram/output_5G
#time bin/hadoop jar hadoop-download-examples.jar com.hadoop.examples.anagrams.AnagramJob /jinho/wordcount/input/dir_1G /jinho/anagram/output_1G

echo time bin/hadoop jar hadoop-download-examples.jar com.hadoop.examples.anagrams.AnagramJob /jinho/anagram/input /jinho/anagram/output
time bin/hadoop jar hadoop-download-examples.jar com.hadoop.examples.anagrams.AnagramJob /jinho/anagram/input /jinho/anagram/output

#echo time bin/hadoop jar hadoop-download-examples.jar com.hadoop.examples.anagrams.AnagramJob /jinho/general/input /jinho/anagram/output
#time bin/hadoop jar hadoop-download-examples.jar com.hadoop.examples.anagrams.AnagramJob /jinho/general/input /jinho/anagram/output
