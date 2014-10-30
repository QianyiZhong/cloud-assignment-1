package beanstalk;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.PropertiesCredentials;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.ec2.AmazonEC2;
import com.amazonaws.services.ec2.AmazonEC2Client;
import com.amazonaws.services.ec2.model.DescribeInstancesResult;
import com.amazonaws.services.ec2.model.Instance;
import com.amazonaws.services.ec2.model.Reservation;
import com.amazonaws.services.elasticloadbalancing.AmazonElasticLoadBalancingClient;
import com.amazonaws.services.elasticloadbalancing.model.CreateLoadBalancerRequest;
import com.amazonaws.services.elasticloadbalancing.model.CreateLoadBalancerResult;
import com.amazonaws.services.elasticloadbalancing.model.Listener;
import com.amazonaws.services.elasticloadbalancing.model.RegisterInstancesWithLoadBalancerRequest;
import com.amazonaws.services.elasticloadbalancing.model.RegisterInstancesWithLoadBalancerResult;

public class LoadBalancer {
    public static void main(String[] args) throws IOException
    {

	  //Set credentials
	    System.out.println("#1 Set credentials..");
	    AWSCredentials credentials = new PropertiesCredentials(BeanStalkStart.class.getResourceAsStream("AwsCredentials.properties"));
        AmazonEC2 ec2 = new AmazonEC2Client(credentials);
        Region usEast1 = Region.getRegion(Regions.US_EAST_1);
        ec2.setRegion(usEast1);
        
    	//create load balancer
        CreateLoadBalancerRequest lbRequest = new CreateLoadBalancerRequest();
        lbRequest.setLoadBalancerName("loader");
        List<Listener> listeners = new ArrayList<Listener>(1);
        listeners.add(new Listener("HTTP",80,80));
        lbRequest.withAvailabilityZones("us-east-1c");
        lbRequest.setListeners(listeners);
       
        AmazonElasticLoadBalancingClient elb = new AmazonElasticLoadBalancingClient(credentials);
        CreateLoadBalancerResult lbResult= elb.createLoadBalancer(lbRequest);
        System.out.println("created load balancer loader");
        
        //get the running instances
        DescribeInstancesResult describeInstancesRequest = ec2.describeInstances();
        List<Reservation> reservations = describeInstancesRequest.getReservations();
        List<Instance> instances = new ArrayList<Instance>();

        for (Reservation reservation : reservations) {
            instances.addAll(reservation.getInstances());
        }


        //get instance id's
        String id;
        List<com.amazonaws.services.elasticloadbalancing.model.Instance> instanceId=new ArrayList<com.amazonaws.services.elasticloadbalancing.model.Instance>();
        List<String> instanceIdString=new ArrayList<String>();
        Iterator<Instance> iterator=instances.iterator();
        while (iterator.hasNext())
        {
            id=iterator.next().getInstanceId();
            instanceId.add(new com.amazonaws.services.elasticloadbalancing.model.Instance(id));
            instanceIdString.add(id);
        }


        //register the instances to the balancer
        RegisterInstancesWithLoadBalancerRequest register =new RegisterInstancesWithLoadBalancerRequest();
        register.setLoadBalancerName("loader");
        register.setInstances(instanceId);
        RegisterInstancesWithLoadBalancerResult registerWithLoadBalancerResult= elb.registerInstancesWithLoadBalancer(register);
    }
}
