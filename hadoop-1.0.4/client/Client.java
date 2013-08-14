import java.lang.*;
import java.io.*;
import java.util.*;
import java.net.*;

public class Client {
	
  public static void main(String[] args) throws IOException {
	String host = "192.168.1.222";
	int port = 8888;
	String fileName="monitor.txt";
	Process pid = null;
	String cmd = "bash monitor.sh";
	String line = null;
	BufferedReader in = null;
	PrintWriter out = null;
	Socket socket = null;
	
	try {
	  socket = new Socket(host, port);
	  out = new PrintWriter(new BufferedWriter(new OutputStreamWriter(socket.getOutputStream())), true);
	
	  while(true) {
	    pid = Runtime.getRuntime().exec(cmd);
            pid.waitFor();
            int success = pid.exitValue();
            if ( success != 0 )
    	      System.out.println("fail to execute monitor.sh");
            pid.destroy();
      
	    File file=new File(fileName);
	    in = new BufferedReader(new FileReader(file));

            while((line=in.readLine())!=null){
              out.println(line);
            }
        
            Thread.sleep(20000);
	   }
	  }  catch (Exception e1) {
		   e1.printStackTrace();
	  }
	  
    finally {
      if(socket != null) {
    	socket.close();
      }
      if(in != null) {
        in.close();
      }
      if(out != null) {
        out.close();
      }
      
    }
  }
 }
