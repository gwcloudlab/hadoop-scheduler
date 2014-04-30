-----
MIMP Deadline Aware Hadoop Scheduler
-----
TEAM MEMBERS: Wei Zhang, Sunny Rajasekran, Timothy Wood, and Mingfa Zhu

MIMP scheduler
---

This version of hadoop scheduler is a deadline-based hadoop scheduler that uses a hybrid cluster of dedicated and residual resources.

The jobQueue is sorted by deadline. When selecting tasks, firstly select the tasks that the job that will miss the deadline. If all jobs can meet their deadline, then the tasks that the job will make the most progress from the free slot will get to use it.

The main modification

1)Add the code that recieve the deadline that the user defines

2)The jobQueue is sorted by the deadline

3)Add some statistical information eg, map task exec time, reduce task exec time and so on

4)After finishing the job, whether the job meets the deadline

5)A program running on each tasktracker node connetcts to the hadoop scheduler and sends resource statistics Using xentop periodically to get the available resources of tasktracker

6)JobTracker has a server socket that receives these stats and stores them into a resource object For each tasktracker, server side will create a receiveThread to receive the stats

7)For each job, predict task exection time based on the reources available

8)Use canMeetDeadline to decide whether a job can meet the deadline based on the current slots

9)When have free slots, firstly select missed deadline job from the jobQueue. If all jobs can meet the deadline, select the job that has the most progress on this free slot

FIFO scheduler
---

1)In the job run queue, sort the jobs according to the arrive time

2)Select the next running job according to the arriving time

EDF scheduler
---

1)In the job run queue, sort the jobs according to the deadline

2)Select the next running job according to the deadline

How to use?

1)./bin/start-all.sh

It will run jobtracer, tasktracker, namenode, datanode on the specific nodes according to your configure 

Start hadoop process

If you want to use MIMP scheduler, you also need to start client side on physical server that tasktracer is located on. The client side will report cpu and disk usage.

Start the client

ssh root@192.168.1.$host "cd client_directory; nohup java Client </dev/null >log.txt 2>&1 &"

2)jobname_deadline.sh [deadline][map tasks or file data size]

After that, you can run hadoop jobs. Each job, there is a shell script, named jobname_deadline.sh

Eg, run pi job with deadline

if we want to give the deadline 300s, map tasks 500, the command line should be like this

./pi_deadline.sh 300 500 

3) ./bin/stop-all.sh

If you want to stop the hadoop processes, run ./bin/stop-all.sh

FIFO and EDF have the same usage with MIMP scheduler

If you change something in the code, in the root directory, run the command

1)ant clean

2)ant

3)go to build/classes directory

jar cvf hadoop-core-1.0.4.jar *

4)copy this jar file to root directory

cp hadoop-core-1.0.4.jar ../..

Xen CPU Scheduler
-----
The modified Xen CPU scheduler described in this paper is available at:
https://github.com/gwcloudlab/xen-interference

Paper
-----
MIMP: Deadline and Interference Aware Scheduling of Hadoop Virtual Machines. Wei Zhang, Sundaresan Rajasekaran, Timothy Wood, Mingfa Zhu. IEEE/ACM International Symposium on Cluster, Cloud and Grid Computing, May 2014. 
http://faculty.cs.gwu.edu/~timwood/papers/14-CCGrid-mimp.pdf

This work was sponsored in part by NSF Grant CNS-1253575.  Wei Zhang and Mingfa Zhu were supported in part by the National Natural Science Foundation of China Grant No. 61370059, 61232009, and Beijing Natural Science Foundation Grant No. 4122042.


License
-----
The original Hadoop source code was released under the Apache 2.0 license. Our changes and supplementary code follow the same terms.
