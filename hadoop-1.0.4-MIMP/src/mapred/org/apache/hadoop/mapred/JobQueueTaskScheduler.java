/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.hadoop.mapred;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.io.*;
import java.lang.*;
import java.util.*;
import java.net.*;

//add by wei
//import java.util.Math;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.mapreduce.server.jobtracker.TaskTracker;

//add by wei
import org.apache.hadoop.mapred.NodeResource;

/**
 * A {@link TaskScheduler} that keeps jobs in a queue in priority order (FIFO
 * by default).
 */
class JobQueueTaskScheduler extends TaskScheduler {
  
  private static final int MIN_CLUSTER_SIZE_FOR_PADDING = 3;
  public static final Log LOG = LogFactory.getLog(JobQueueTaskScheduler.class);
  
  protected JobQueueJobInProgressListener jobQueueJobInProgressListener;
  protected EagerTaskInitializationListener eagerTaskInitializationListener;
  private float padFraction;
    
  //add by wei
  protected static double DISKTHRESHOLD = 200000;
  protected static int REPLICATION = 6;
  protected static  Map<String, NodeResource> resources
    = new HashMap<String, NodeResource>();
  protected volatile boolean running = false;
  protected static int pickDeadline = 0, pickProgress = 0, pickNone = 0;
  
  public JobQueueTaskScheduler() {
    this.jobQueueJobInProgressListener = new JobQueueJobInProgressListener();
  }

/*  public void initResources() {
    NodeResource nodeMasterTest = new NodeResource(0, 0);
    resources.put("mastertest", nodeMasterTest);
    NodeResource nodeSlave1Test = new NodeResource(0, 0);
    resources.put("slave1test", nodeSlave1Test);
  }*/


  
  @Override
  public synchronized void start() throws IOException {
    try {
      super.start();
      taskTrackerManager.addJobInProgressListener(jobQueueJobInProgressListener);
      eagerTaskInitializationListener.setTaskTrackerManager(taskTrackerManager);
      eagerTaskInitializationListener.start();
      taskTrackerManager.addJobInProgressListener(
          eagerTaskInitializationListener);
      running = true;
      initResources();
      new UpdateResourceThread().start();
    } catch (Exception e) {
      LOG.error("Failed to start threads ", e);
    }
  }
  
  @Override
  public synchronized void terminate() throws IOException {
    if (jobQueueJobInProgressListener != null) {
      taskTrackerManager.removeJobInProgressListener(
          jobQueueJobInProgressListener);
    }
    if (eagerTaskInitializationListener != null) {
      taskTrackerManager.removeJobInProgressListener(
          eagerTaskInitializationListener);
      eagerTaskInitializationListener.terminate();
    }
    super.terminate();
    running=false;
  }
  
  @Override
  public synchronized void setConf(Configuration conf) {
    super.setConf(conf);
    padFraction = conf.getFloat("mapred.jobtracker.taskalloc.capacitypad", 
                                 0.01f);
    this.eagerTaskInitializationListener =
      new EagerTaskInitializationListener(conf);
  }

  @Override
  public synchronized List<Task> assignTasks(TaskTracker taskTracker)
      throws IOException {
    
    // Assigned tasks
    List<Task> assignedTasks = new ArrayList<Task>();
   
    TaskTrackerStatus taskTrackerStatus = taskTracker.getStatus(); 
    ClusterStatus clusterStatus = taskTrackerManager.getClusterStatus();
    final int numTaskTrackers = clusterStatus.getTaskTrackers();
    final int clusterMapCapacity = clusterStatus.getMaxMapTasks();
    final int clusterReduceCapacity = clusterStatus.getMaxReduceTasks();

    Collection<JobInProgress> jobQueue =
      jobQueueJobInProgressListener.getJobQueue();

    //
    // Get map + reduce counts for the current tracker.
    //
    final int trackerMapCapacity = taskTrackerStatus.getMaxMapSlots();
    final int trackerReduceCapacity = taskTrackerStatus.getMaxReduceSlots();
    final int trackerRunningMaps = taskTrackerStatus.countMapTasks();
    final int trackerRunningReduces = taskTrackerStatus.countReduceTasks();


    //
    // Compute (running + pending) map and reduce task numbers across pool
    //
    int remainingReduceLoad = 0;
    int remainingMapLoad = 0;
    synchronized (jobQueue) {
      for (JobInProgress job : jobQueue) {
        int jobOccupiedSlots = 0;
        Set<Map.Entry<String, Integer>> entries = job.getSlotsHashMap().entrySet();
        for (Map.Entry<String, Integer> entry:entries) {
          String host = entry.getKey();
          Integer slotsNum = entry.getValue();
          jobOccupiedSlots += slotsNum;
	  System.out.printf("***Time=%d, jobName=%s, jobID=%s, host=%s, slots=%d %n", System.currentTimeMillis(), job.getProfile().getJobName(), job.getJobID().toString(), host, slotsNum);
	}
	System.out.printf("***Time=%d, JobName=%s, JobID=%s, Slots=%d %n", System.currentTimeMillis(), job.getProfile().getJobName(), job.getJobID().toString(), jobOccupiedSlots);
	
        if (job.getStatus().getRunState() == JobStatus.RUNNING) {
          remainingMapLoad += (job.desiredMaps() - job.finishedMaps());
          if (job.scheduleReduces()) {
            remainingReduceLoad += 
              (job.desiredReduces() - job.finishedReduces());
          }
        }
      }
    }

    // Compute the 'load factor' for maps and reduces
    double mapLoadFactor = 0.0;
    if (clusterMapCapacity > 0) {
      mapLoadFactor = (double)remainingMapLoad / clusterMapCapacity;
    }
    double reduceLoadFactor = 0.0;
    if (clusterReduceCapacity > 0) {
      reduceLoadFactor = (double)remainingReduceLoad / clusterReduceCapacity;
    }
        
    //
    // In the below steps, we allocate first map tasks (if appropriate),
    // and then reduce tasks if appropriate.  We go through all jobs
    // in order of job arrival; jobs only get serviced if their 
    // predecessors are serviced, too.
    //

    //
    // We assign tasks to the current taskTracker if the given machine 
    // has a workload that's less than the maximum load of that kind of
    // task.
    // However, if the cluster is close to getting loaded i.e. we don't
    // have enough _padding_ for speculative executions etc., we only 
    // schedule the "highest priority" task i.e. the task from the job 
    // with the highest priority.
    //
    
    final int trackerCurrentMapCapacity = 
      Math.min((int)Math.ceil(mapLoadFactor * trackerMapCapacity), 
                              trackerMapCapacity);
    int availableMapSlots = trackerCurrentMapCapacity - trackerRunningMaps;
    boolean exceededMapPadding = false;
    if (availableMapSlots > 0) {
      exceededMapPadding = 
        exceededPadding(true, clusterStatus, trackerMapCapacity);
    }
    
    int numLocalMaps = 0;
    int numNonLocalMaps = 0;
    boolean canMeetDeadline = false;
    int j = 0;
    boolean diskBottleneck = false;

    String host = taskTracker.getStatus().getHost();
    NodeResource nodeResource = resources.get(host);
  //  System.out.printf("+++current time:%d, nodeResource address:%s, cpu usage:%f %n", System.currentTimeMillis(), 
 //                     Integer.toHexString(System.identityHashCode(nodeResource)), nodeResource.getCpuUsage());
//    System.out.printf("$$$The total map free slots in TaskTracker %s is %d %n", taskTracker.getStatus().getHost(), availableMapSlots);
    scheduleMaps:
    for (int i=0; i < availableMapSlots; ++i) {
      JobInProgress job = null;
      JobInProgress firstJob = null;
      JobInProgress maxProgressJob = null;
      synchronized (jobQueue) {
        for (JobInProgress jobTmp : jobQueue) {
  //      System.out.printf("!!!JobName=%s Deadline=%d %n", jobTmp.getProfile().getJobName(), jobTmp.getJobDeadline());  
/*	if(firstJob == null && jobTmp.getStatus().getRunState() == JobStatus.RUNNING ) {
            firstJob = jobTmp;
            j = i + 1;
          }*/
   
          if (jobTmp.getStatus().getRunState() != JobStatus.RUNNING) {
            continue;
          }
          canMeetDeadline = canMeetDeadline(jobTmp);
 //         System.out.printf("***JobName=%s, canMeetDeadline=%b, currentTime=%d %n", jobTmp.getProfile().getJobName(), canMeetDeadline, System.currentTimeMillis()); 
          //add by wei
          if (!canMeetDeadline) {
            /* Always pick a job if it cannot meet its deadline, ignoring potential IO bottleneck */
            job = jobTmp;
     //         j = i + 1;
            break;
          }
          else if (!diskBottleneck(jobTmp, taskTracker)) {
              if((maxProgressJob == null) || 
                  (predictMapNormalizedTct(jobTmp, nodeResource) < predictMapNormalizedTct(maxProgressJob, nodeResource))) {
                /* This job does not cause IO bottleneck and will make the most progress of those seen so far. */
                maxProgressJob = jobTmp; 
              }
         }
	
	}
     
        //add by wei
        // Check if we found a job that could not meet deadline
        if (job == null) { /* ALl jobs can meet deadline */
      	  if(maxProgressJob != null) {
      	    job = maxProgressJob; /* Pick the job that will make the most progress */
	    pickProgress++;
           System.out.printf("time=%d, jobID=%s, jobName=%s has the maximum progress for the current jobs%n", System.currentTimeMillis(), job.getJobID().toString(), job.getProfile().getJobName());
      	  }
      	  else {
      	    // any job we pick will cause IO bottleneck
	    pickNone++;
            System.out.printf("time=%d, no job is selected, becasue of IO bottleneck %n", System.currentTimeMillis());
      	    break;
      	  }
	}
	else{
          pickDeadline++;
        }
	// if we reach here, we have found a job to run

     //   job = jobQueue.iterator.next();
     //     job = firstJob;

    /*    if(job == null)
          job = maxProgressJob;*/
        
      //  System.out.printf("@@@Job %s gets the %dth map free slot from TaskTracker %s %n", job.getProfile().getJobName(), j, taskTracker.getStatus().getHost());
        System.out.printf("@@@Job %s gets the map free slot from TaskTracker %s %n", job.getProfile().getJobName(), taskTracker.getStatus().getHost());

        double predictMapNormalizedTct = predictMapNormalizedTct(job, nodeResource);      
        double predictMapTaskExecTime = dedicatedMapTaskExecTime(job) * predictMapNormalizedTct; 

          Task t = null;
          
          // Try to schedule a node-local or rack-local Map task
          t = 
            job.obtainNewNodeOrRackLocalMapTask(taskTrackerStatus, 
                numTaskTrackers, taskTrackerManager.getNumberOfUniqueHosts());
          if (t != null) {
            assignedTasks.add(t);
            ++numLocalMaps;
             
            job.putTaskInfo(t, predictMapTaskExecTime, host);
	    System.out.printf("time=%d, pickDeadline=%d, pickProgress=%d, pickNone=%d %n", System.currentTimeMillis(), pickDeadline, pickProgress, pickNone);
            
            // Don't assign map tasks to the hilt!
            // Leave some free slots in the cluster for future task-failures,
            // speculative tasks etc. beyond the highest priority job
            if (exceededMapPadding) {
              break scheduleMaps;
            }
           
            // Try all jobs again for the next Map task 
            break;
          }
          
          // Try to schedule a node-local or rack-local Map task
          t = 
            job.obtainNewNonLocalMapTask(taskTrackerStatus, numTaskTrackers,
                                   taskTrackerManager.getNumberOfUniqueHosts());
          
          if (t != null) {
            assignedTasks.add(t);
            ++numNonLocalMaps;
       
            job.putTaskInfo(t, predictMapTaskExecTime, host);
	          System.out.printf("time=%d, pickDeadline=%d, pickProgress=%d, pickNone=%d %n", System.currentTimeMillis(), pickDeadline, pickProgress, pickNone);
            
            // We assign at most 1 off-switch or speculative task
            // This is to prevent TaskTrackers from stealing local-tasks
            // from other TaskTrackers.
            break scheduleMaps;
          }

        if (t == null) {
	  //System.out.printf("Time=%d, node=%s, JobID=%s, JobName=%s did not  allocate map task %n", System.currentTimeMillis(), host, job.getJobID().toString(), job.getProfile().getJobName());
	  System.out.printf("Time=%d, JobID=%s, JobName=%s did not  allocate map task %n", System.currentTimeMillis(), job.getJobID().toString(), job.getProfile().getJobName());
        }
      }
 
    }
    int assignedMaps = assignedTasks.size();

    //
    // Same thing, but for reduce tasks
    // However we _never_ assign more than 1 reduce task per heartbeat
    //
    final int trackerCurrentReduceCapacity = 
      Math.min((int)Math.ceil(reduceLoadFactor * trackerReduceCapacity), 
               trackerReduceCapacity);
    final int availableReduceSlots = 
      Math.min((trackerCurrentReduceCapacity - trackerRunningReduces), 1);
    boolean exceededReducePadding = false;
    if (availableReduceSlots > 0) {
      exceededReducePadding = exceededPadding(false, clusterStatus, 
                                              trackerReduceCapacity);
      synchronized (jobQueue) {
        for (JobInProgress job : jobQueue) {
          if (job.getStatus().getRunState() != JobStatus.RUNNING ||
              job.numReduceTasks == 0) {
            continue;
          }

          Task t = 
            job.obtainNewReduceTask(taskTrackerStatus, numTaskTrackers, 
                                    taskTrackerManager.getNumberOfUniqueHosts()
                                    );
          if (t != null) {
            assignedTasks.add(t);
            break;
          }
          
          // Don't assign reduce tasks to the hilt!
          // Leave some free slots in the cluster for future task-failures,
          // speculative tasks etc. beyond the highest priority job
          if (exceededReducePadding) {
            break;
          }
        }
      }
    }
    
    if (LOG.isDebugEnabled()) {
      LOG.debug("Task assignments for " + taskTrackerStatus.getTrackerName() + " --> " +
                "[" + mapLoadFactor + ", " + trackerMapCapacity + ", " + 
                trackerCurrentMapCapacity + ", " + trackerRunningMaps + "] -> [" + 
                (trackerCurrentMapCapacity - trackerRunningMaps) + ", " +
                assignedMaps + " (" + numLocalMaps + ", " + numNonLocalMaps + 
                ")] [" + reduceLoadFactor + ", " + trackerReduceCapacity + ", " + 
                trackerCurrentReduceCapacity + "," + trackerRunningReduces + 
                "] -> [" + (trackerCurrentReduceCapacity - trackerRunningReduces) + 
                ", " + (assignedTasks.size()-assignedMaps) + "]");
    }

    return assignedTasks;
    
  }

  private boolean exceededPadding(boolean isMapTask, 
                                  ClusterStatus clusterStatus, 
                                  int maxTaskTrackerSlots) { 
    int numTaskTrackers = clusterStatus.getTaskTrackers();
    int totalTasks = 
      (isMapTask) ? clusterStatus.getMapTasks() : 
        clusterStatus.getReduceTasks();
    int totalTaskCapacity = 
      isMapTask ? clusterStatus.getMaxMapTasks() : 
                  clusterStatus.getMaxReduceTasks();

    Collection<JobInProgress> jobQueue =
      jobQueueJobInProgressListener.getJobQueue();

    boolean exceededPadding = false;
    synchronized (jobQueue) {
      int totalNeededTasks = 0;
      for (JobInProgress job : jobQueue) {
        if (job.getStatus().getRunState() != JobStatus.RUNNING ||
            job.numReduceTasks == 0) {
          continue;
        }

        //
        // Beyond the highest-priority task, reserve a little 
        // room for failures and speculative executions; don't 
        // schedule tasks to the hilt.
        //
        totalNeededTasks += 
          isMapTask ? job.desiredMaps() : job.desiredReduces();
        int padding = 0;
        if (numTaskTrackers > MIN_CLUSTER_SIZE_FOR_PADDING) {
          padding = 
            Math.min(maxTaskTrackerSlots,
                     (int) (totalNeededTasks * padFraction));
        }
        if (totalTasks + padding >= totalTaskCapacity) {
          exceededPadding = true;
          break;
        }
      }
    }

    return exceededPadding;
  }

  @Override
  public synchronized Collection<JobInProgress> getJobs(String queueName) {
    return jobQueueJobInProgressListener.getJobQueue();
  }  

  public double predictMapTaskExecTime(JobInProgress job) {
    double mapTaskExecTime = 0;
    String jobName = job.getProfile().getJobName();
    if (jobName.equals("PiEstimator")) {
      mapTaskExecTime = 5;
    }  else if (jobName.equals("word count")) {
    	  mapTaskExecTime = 40;
    }  else if (jobName.equals("TeraSort")) {
          mapTaskExecTime = 7.5;
    }
    return mapTaskExecTime;
  } 


  public double dedicatedMapTaskExecTime(JobInProgress job) {
    double dedicatedMapTaskExecTime = 0;
    String jobName = job.getProfile().getJobName();
    if (jobName.equals("PiEstimator")) {
      dedicatedMapTaskExecTime = 8845;
    }  else if (jobName.equals("word count")) {
    	  dedicatedMapTaskExecTime = 80472;
    }  else if (jobName.equals("TeraSort")) {
          dedicatedMapTaskExecTime = 53382;
    }  else if (jobName.equals("sorter")) {
    	  dedicatedMapTaskExecTime = 65804;
    }  else if (jobName.equals("grep-search")) {
    	  dedicatedMapTaskExecTime = 37872;
    }  else if (jobName.equals("grep-sort")) {
    	  dedicatedMapTaskExecTime = 8523;
    }  else if (jobName.contains("Iterator")) {
	    dedicatedMapTaskExecTime = 22742;
    }  else if (jobName.contains("Classification")) {
	    dedicatedMapTaskExecTime = 62157;
    }

    return dedicatedMapTaskExecTime;
  }

  public double predictMapNormalizedTct(JobInProgress job, NodeResource nodeResource) {
	  double mapNormalizedTct = 0;
	  double webCpuUsage = nodeResource.getCpuUsage();
	  double a = 0;
	  double b = 0;
	  double c = 0;
	  double d = 0;
	  String jobName = job.getProfile().getJobName();
	  if (jobName.equals("PiEstimator")) {
		  a = 1.01;  
		  b = 0.00494;  
		  c = 0.0001694;  
		  d = 0.05609;   
	  }  else if (jobName.equals("word count")) {
		  a = 1.031;  
		  b = 0.002871;  
		  c = 0.0002912;  
		  d = 0.05064;  
	  }  else if (jobName.equals("TeraSort")) {

		  a = 0.001605;  
		  b = 0.04108;  
		  c = 1.104;  
		  d = 0.002533;
	  } else if (jobName.equals("sorter")) {
		  a = 0.7689;  
		  b = 0.005868;  
		  c = 0;  
		  d = -7.699;  

	  } else if (jobName.equals("grep-search")) {
		  a = 0.6553;  
		  b = 0.009691;  
		  c = 0;  
		  d = -7.699;  
	  } else if (jobName.equals("grep-sort")) {
		  a = 0.7887;  
		  b = 0.006898;  
		  c = 0;  
		  d = -7.699;  
	  } else if (jobName.contains("Iterator")){
		  a = 0.3243;
		  b = 0.01472;
		  c = 0;
		  d = -7.699;
	  } else if (jobName.contains("Classification")){
       		  a = 0.3766;
       		  b = 0.01537;
       		  c = 0;
       		  d = -7.699;    
    }

    mapNormalizedTct = a * Math.exp(b * webCpuUsage) + c * Math.exp(d * webCpuUsage);
    return mapNormalizedTct;
  }

/*  public double jobProgress(JobInProgress job, NodeResource nodeResource){
    double jobProgress = 0;

    NodeResource dedicatedNodeResource =  new NodeResource(0, 0);
    jobProgress = predictMapTaskExecTime(job, dedicatedNodeResource) / (predictMapTaskExecTime(job, nodeResource));

    return jobProgress;

  }*/
                                 
/*  public boolean canMeetDeadline(JobInProgress job){
    boolean canMeetDeadline;
    int pendingMapTasks;
    int currentMapSlots;
    double dedicatedMapTaskExecTime;
    long remainingTime;
    NodeResource dedicatedNodeResource = null;

    dedicatedNodeResource = new NodeResource(0);
    pendingMapTasks = job.pendingMaps();
    currentMapSlots = job.runningMaps();
    remainingTime = (job.getJobDeadline() - System.currentTimeMillis());
    dedicatedMapTaskExecTime = predictMapTaskExecTime(job, dedicatedNodeResource);
    if (currentMapSlots == 0) {
      canMeetDeadline = false;
      return canMeetDeadline;
    }
    canMeetDeadline = (pendingMapTasks * dedicatedMapTaskExecTime * 1000 / currentMapSlots < remainingTime);
    return canMeetDeadline;  
  
 }*/

/*public double predictJobDiskDemand(JobInProgress job) {
  String jobName = job.getProfile().getJobName();
  double diskDemand = 0.0;
    if (jobName.equals("PiEstimator")) {
      diskDemand = 10.0;
    }  else if (jobName.equals("word count")) {
        diskDemand = 20.0;
    }  else if (jobName.equals("TeraSort")) {
        diskDemand = 15.0;
    }   
    return diskDemand; 

}*/

public double predictTaskDiskDemand(JobInProgress job, TaskTracker taskTracker) {
  String jobName = job.getProfile().getJobName();
  String taskTrackerHost = taskTracker.getStatus().getHost();
  NodeResource nodeResource = resources.get(taskTrackerHost);
  double predictMapNormalizedTct = predictMapNormalizedTct(job, nodeResource);      
  double diskDemand = 0.0;
  double diskDemandwithFullCpu = 0.0; 
    if (jobName.equals("PiEstimator")) {
      diskDemandwithFullCpu = 0;
    }  else if (jobName.equals("word count")) {
      diskDemandwithFullCpu = 8314.666667;
    }  else if (jobName.equals("TeraSort")) {
      diskDemandwithFullCpu = 51149.33333;
    }  else if (jobName.equals("sorter")) {
      diskDemandwithFullCpu = 71728 ;
    }  else if (jobName.equals("grep-search")) {
      diskDemandwithFullCpu = 27373.33333;
    }  else if (jobName.equals("grep-sort")) {
      diskDemandwithFullCpu = 0;
    }  else if (jobName.contains("Iterator")) {
      diskDemandwithFullCpu = 2068;
    }  else if (jobName.contains("Classification")) {
      diskDemandwithFullCpu = 0;
    }

  
    diskDemand = diskDemandwithFullCpu / (predictMapNormalizedTct * REPLICATION);
    return diskDemand; 
}

public boolean diskBottleneck(JobInProgress job, TaskTracker taskTracker) {
  String taskTrackerHost = taskTracker.getStatus().getHost();
  double taskTrackerCpuUsage = resources.get(taskTrackerHost).getCpuUsage();

  double predictDiskDemand = predictTaskDiskDemand(job, taskTracker);

  if ((int)predictDiskDemand == 0 ) {
	return false;
  }
   
  Set<Map.Entry<String, NodeResource>> entries = resources.entrySet();
  for (Map.Entry<String, NodeResource> entry:entries) {
    String host = entry.getKey();
    NodeResource nodeResource = entry.getValue();
    double cpu = nodeResource.getCpuUsage();
    double disk = nodeResource.getDisk();
    boolean isDedicated = false;
    if(cpu == 0) {
	    isDedicated = true;
    }
    if (isDedicated && disk + predictDiskDemand > DISKTHRESHOLD) {
      System.out.printf("Time=%d, jobID=%s, jobName=%s, predictDiskDemand=%f, currentDiskBW=%f, MaxDisk=%f bring datanode %s IO bottleneck %n", System.currentTimeMillis(), job.getJobID().toString(), job.getProfile().getJobName(), predictDiskDemand, disk, DISKTHRESHOLD, host);
      return true;
    }
  }

  return false;
}

  /* Can job meet its deadline with its currently allocated slots? */
  public boolean canMeetDeadline(JobInProgress job){
    boolean canMeetDeadline = false;
    int pendingMapTasks;
    long remainingTime;
//    int[] taskNums = new int[100];
    int totalTaskNums = 0;
//    int i = 0;
    int totalOccupiedSlots = 0;
    double overallTct = 0.0;
    double tmpTct = 0.0;
    double predictMapPhaseJct = 0.0;
	
    double cleanupTime = 65000;

/*    if (job.getJobRelativeDeadline() == 65535) {
      return true;
    }*/

    pendingMapTasks = job.pendingMaps();
  
  /*  if (pendingMapTasks == 0)
    {
      System.out.printf("Time=%d, jobID=%s, jobName=%s has no pending tasks %n", System.currentTimeMillis(), job.getJobID().toString(), job.getProfile().getJobName());
      return false;
    }*/
    remainingTime = (job.getJobDeadline() - System.currentTimeMillis());

    // FORCE IMMEDIATE RETURN
/*
    if(totalTaskNums == 0) {
      return false;
    }*/

    Set<Map.Entry<String, Integer>> entries = job.getSlotsHashMap().entrySet();
    for (Map.Entry<String, Integer> entry:entries) {
      String host = entry.getKey();
      Integer slotsNum = entry.getValue();
      totalOccupiedSlots += slotsNum;
      NodeResource nodeResource = resources.get(host);
      double predictMapNormalizedTct = predictMapNormalizedTct(job, nodeResource);      
      double predictMapTaskExecTime = dedicatedMapTaskExecTime(job) * predictMapNormalizedTct; 
      tmpTct += predictMapTaskExecTime * slotsNum; 
//      taskNums[i] = (int)(remainingTime / (predictMapTaskExecTime * 1000)) * slotsNum;
      totalTaskNums += (int)((remainingTime-cleanupTime) / predictMapTaskExecTime ) * slotsNum;
//      System.out.printf("AAAjobName=%s, host=%s, slotsNum=%d, TaskExecTime=%f, pendingTasks=%d, TaskNums=%d %n", job.getProfile().getJobName(), 
//                        host, slotsNum, predictMapTaskExecTime, pendingMapTasks, (int)(remainingTime / (predictMapTaskExecTime * 1000)) * slotsNum);
//      i++;      
    }

    if ( totalOccupiedSlots != 0) {

      predictMapPhaseJct = System.currentTimeMillis() - job.getStartTime() + pendingMapTasks * tmpTct / (totalOccupiedSlots * totalOccupiedSlots);
      System.out.printf("time=%d, jobID=%s, jobName=%s, predictMapPhaseJct=%f %n", System.currentTimeMillis(), job.getJobID().toString(), job.getProfile().getJobName(), predictMapPhaseJct);

    }
     
/*    for (i = 0; i < taskNums.length; i++) {
      totalTaskNums += taskNums[i];
    }*/

   // adding some extra, try to make all tasks can be finished before the deadline 
   // if (totalTaskNums >= (pendingMapTasks*1.08))
 /*
   String jobName = job.getProfile().getJobName();
   double factor = 1;
   if (jobName.equals("PiEstimator")) {
   	factor = 50;	
   } else if (jobName.equals("word count")) {
        factor = 0.8;
   } else if (jobName.equals("TeraSort")) {
        factor = 1.5;
   }
   
   if (totalTaskNums >= ((int)Math.ceil(factor*pendingMapTasks))) {*/
   if (totalTaskNums >= pendingMapTasks) {
      canMeetDeadline = true;
 
    }
    else {
      canMeetDeadline = false;
      System.out.printf("time=%d, jobID=%s, jobName=%s MISS DEADLINE, need more slots %n", System.currentTimeMillis(), job.getJobID().toString(), job.getProfile().getJobName());
   }
    return canMeetDeadline;  
  
 }

public void initResources() {
   String fileName="/home/hadoop/nodes.txt";
   File file=new File(fileName);
   BufferedReader br = null;
   String node="";
   try {
     br=new BufferedReader(new FileReader(file));
   } catch (FileNotFoundException e) {
     LOG.error("Can not find resource.txt file", e);
   }

   NodeResource nodeResource = new NodeResource(0, 0);
   try {
     while((node=br.readLine())!=null){
        resources.put(node, nodeResource);
     }

  } catch (IOException e1) {
     LOG.error("Exception in reading resource.txt file", e1);
  }

}

 public void updateNodeResources() {
   String fileName="/home/hadoop/resource.txt";
   File file=new File(fileName);
   BufferedReader br = null;
   String host="";
   double cpu=0;
  
   try {
     br=new BufferedReader(new FileReader(file));
   } catch (FileNotFoundException e) {
     LOG.error("Can not find resource.txt file", e);
   } 
     String line=null;
     String[] rec=null;
   try {
   while((line=br.readLine())!=null){
     rec=line.split("\t");
     host=rec[0];
     cpu=Double.parseDouble(rec[1]);
     NodeResource nodeResource = new NodeResource(cpu);
     synchronized (resources) {
       resources.put(host, nodeResource);
     }
     
   }
  } catch (IOException e1) {
    LOG.error("Exception in reading resource.txt file", e1);
  }
 }  

  private class ReceiveThread extends Thread {
    private Socket clientSocket;
    private BufferedReader in;

    public ReceiveThread(Socket s) {
      this.clientSocket = s;
      try {
        this.in = new BufferedReader(new InputStreamReader(this.clientSocket.getInputStream()));
        start();
      } catch(IOException e) {
          LOG.error("Exception in ReceiveThread");
      }
    }
    public void run() {
      String line;
      try {
        while(true) {
          line = in.readLine();
          String[] rec = line.split("\t");
          String host = rec[0];
          double cpu = Double.parseDouble(rec[1]);
          double disk = Double.parseDouble(rec[2]);
          NodeResource nodeResource = new NodeResource(cpu, disk);
          synchronized(resources){
            resources.put(host, nodeResource);
            NodeResource nodeResource1 = resources.get(host);
  //          System.out.printf("???resources address in ReceiveThread():%s %n", Integer.toHexString(System.identityHashCode(resources)));
  //          System.out.printf("+++current time:%d, nodeResource1 address:%s, host:%s, cpu usage:%f, disk:%f %n", System.currentTimeMillis(), 
  //                           Integer.toHexString(System.identityHashCode(nodeResource1)), host, nodeResource1.getCpuUsage(), nodeResource1.getDisk());
          }
        }
      } catch(IOException e) {
        LOG.error("ReceiveThread run() fail to read data from socket");
      } finally {
        if(in != null) {
          try{
            in.close();
          } catch(IOException e1){
            LOG.error("ReceiveThread run() finally block close exception");
          }
        }

      }

    }
  } 

  private class UpdateResourceThread extends Thread {
    private UpdateResourceThread() {
      super("DeadlineScheduler update thread"); 
    }

    public void run() {
      int port = 8888;
      ServerSocket socket = null;
      try {
      JobQueueTaskScheduler jobQueueTaskScheduler = new JobQueueTaskScheduler();
      socket = new ServerSocket(port);
      socket.setReuseAddress(true);
      while(running) {
        Socket clientScoket = socket.accept();
        jobQueueTaskScheduler.new ReceiveThread(clientScoket);
        } 
      } catch (Exception e) {
          LOG.error("Exception in DeadlineScheduler's UpdateThread", e);
      } finally {
        if(socket != null) {
          try {
            socket.close();
          } catch (IOException e1) {
            LOG.error("Exception in UpdateResourceThread run() finally block socket.close()");
          }
        }
      }

     }
    }

}

