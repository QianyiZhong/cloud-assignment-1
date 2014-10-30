package beanstalk;


import java.io.IOException;

import com.amazonaws.AmazonClientException;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.PropertiesCredentials;
import com.amazonaws.auth.profile.ProfileCredentialsProvider;
import com.amazonaws.services.elasticbeanstalk.AWSElasticBeanstalkClient;
import com.amazonaws.services.elasticbeanstalk.model.CreateApplicationRequest;
import com.amazonaws.services.elasticbeanstalk.model.CreateApplicationResult;
import com.amazonaws.services.elasticbeanstalk.model.CreateApplicationVersionRequest;
import com.amazonaws.services.elasticbeanstalk.model.CreateApplicationVersionResult;
import com.amazonaws.services.elasticbeanstalk.model.CreateEnvironmentRequest;
import com.amazonaws.services.elasticbeanstalk.model.CreateEnvironmentResult;
import com.amazonaws.services.elasticbeanstalk.model.DeleteApplicationRequest;
import com.amazonaws.services.elasticbeanstalk.model.EnvironmentTier;
import com.amazonaws.services.elasticbeanstalk.model.S3Location;

public class BeanStalkStart {
    
	public static void main(String[] args) throws InterruptedException, IOException
	{
		//Set credentials
	    System.out.println("#1 Set credentials..");
	    AWSCredentials credentials = new PropertiesCredentials(BeanStalkStart.class.getResourceAsStream("AwsCredentials.properties"));
        
        //Beanstalk
        System.out.println("#2 Luanch App & Evironment..");
        AWSElasticBeanstalkClient beanstalk = new AWSElasticBeanstalkClient(credentials);
        String applicationName = "TwitterMap";
        String environmentName = "TwitterMapEnvironment";
        DeleteApplicationRequest deleteApplicationRequest = new DeleteApplicationRequest(applicationName);
        beanstalk.deleteApplication(deleteApplicationRequest);
        Thread.sleep(60000);
        CreateApplicationRequest createApplicationRequest = new CreateApplicationRequest(applicationName);
        CreateApplicationResult createApplicationResult = beanstalk.createApplication(createApplicationRequest);
        CreateApplicationVersionRequest createApplicationVersionRequest = new CreateApplicationVersionRequest(applicationName,"1");
        String s3Bucket = "twittermapmengmengda";
        String s3Key = "Web.war";
        S3Location sourceBundle = new S3Location(s3Bucket,s3Key);
        createApplicationVersionRequest.setSourceBundle(sourceBundle);
        createApplicationVersionRequest.withSourceBundle(sourceBundle);
        createApplicationVersionRequest.withVersionLabel("1");
        System.out.print(createApplicationVersionRequest.getSourceBundle());
        CreateApplicationVersionResult createApplicationVersionResult = beanstalk.createApplicationVersion(createApplicationVersionRequest);
        
        CreateEnvironmentRequest createEnvironmentRequest = new CreateEnvironmentRequest(applicationName, environmentName);
        createEnvironmentRequest.setSolutionStackName("64bit Amazon Linux running Tomcat 7");
        EnvironmentTier tier = new EnvironmentTier();
        tier.setName("WebServer");
        tier.setType("Standard");
        tier.setVersion("1.0");
        createEnvironmentRequest.setTier(tier);
        createEnvironmentRequest.setCNAMEPrefix("TwitterMap");
        CreateEnvironmentResult createEnvironmentResult = beanstalk.createEnvironment(createEnvironmentRequest);
        
	}
	
}
