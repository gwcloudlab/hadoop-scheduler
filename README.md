/////////////////////////////////////////////////////////////////////
PROJECT TITLE: Hadoop Scheduler 1.0.4
TEAM MEMBERS: Wei Zhang, Sunny Rajasekran
/////////////////////////////////////////////////////////////////////

This version of hadoop scheduler is a deadline-based hadoop scheduler
that uses a hybrid cluster of dedicated and residual resources. 

The jobQueue is sorted by deadline. When selecting tasks, firstly select 
the tasks that the job that will miss the deadline. If all jobs can meet 
their deadline, then the tasks that the job will make the most progress
from the free slot will get to use it.

The main modification

1)Add the code that recieve the deadline that the user defines

2)The jobQueue is sorted by the deadline

3)Add some statistical information 
eg, map task exec time, reduce task exec time and so on

4)After finishing the job, whether the job meets the deadline

5)A program running on each tasktracker node connetcts to the hadoop 
scheduler and sends resource statistics
Using xentop periodically to get the available resources of tasktracker

6)JobTracker has a server socket that receives these stats and stores 
them into a resource object
For each tasktracker, server side will create a receiveThread to receive 
the stats

7)For each job, predict task exection time based on the reources available

8)Use canMeetDeadline to decide whether a job can meet the deadline based 
on the current slots

9)When have free slots, firstly select missed deadline job from the jobQueue.
If all jobs can meet the deadline, select the job that has the most progress
on this free slot
 


