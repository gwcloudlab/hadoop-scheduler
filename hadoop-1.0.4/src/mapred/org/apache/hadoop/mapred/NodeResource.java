package org.apache.hadoop.mapred;

import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.HashMap;
import java.util.Set;
import java.util.Queue;
import java.lang.*;
import java.io.*;

import org.apache.hadoop.mapreduce.server.jobtracker.TaskTracker;

public class NodeResource {
  private double cpu;
  private double disk;
  private double net;

  public NodeResource(double cpu) {
    this.cpu = cpu;
  }

  public double getCpuUsage() {
    return cpu;
  }
}
