 time ./bin/hadoop jar /home/hadoop/mahout-distribution-0.7/mahout-core-0.7-job.jar org.apache.mahout.clustering.kmeans.KMeansDriver  -D mapred.job.relative.deadline=$1  -c /HiBench/KMeans/Input-comp/cluster -i /HiBench/KMeans/Input-comp/samples -o /HiBench/KMeans/Output-comp -x 1  -ow -cl -cd 0.5  -dm org.apache.mahout.common.distance.EuclideanDistanceMeasure -xm mapreduce

