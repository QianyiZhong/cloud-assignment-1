<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page 
		import = "java.io.*,java.util.*" 
		import = "java.util.Date"
		import = "java.text.DateFormat"
		import = "java.text.SimpleDateFormat"
		import = "java.util.concurrent.ConcurrentHashMap"
		import = "com.amazonaws.services.simpledb.model.Item"
		import = "com.amazonaws.services.simpledb.model.Attribute"
		import ="java.io.BufferedReader"
		import ="java.io.FileInputStream"
		import = "java.io.FileNotFoundException"
		import ="java.io.IOException"
		import = "java.io.InputStreamReader"
		import = "java.io.UnsupportedEncodingException"
		import ="java.net.HttpURLConnection"
		import = "java.net.URL"
		import = "java.text.ParseException"
		import = "java.text.SimpleDateFormat"
		import = "java.util.ArrayList"
		import = "java.util.Date"
		import  = "com.amazonaws.auth.AWSCredentials"
		import = "com.amazonaws.auth.PropertiesCredentials"
		import = "com.amazonaws.regions.Region"
		import = "com.amazonaws.regions.Regions"
		import = "com.amazonaws.services.simpledb.AmazonSimpleDBClient"
		import = "com.amazonaws.services.simpledb.model.SelectRequest"
		import = "com.amazonaws.services.simpledb.model.SelectResult"
		
		import ="java.util.List"
		import = "java.util.Properties"
		
		import = "javax.swing.text.html.parser.Entity"
		
		import ="org.json.JSONArray"
		import ="org.json.JSONException"
		import ="org.json.JSONObject"
		import ="org.omg.CORBA.portable.InputStream"
%>
<%@page import="cloud.DataFetch"%>



<%!//record the number of item in the datastore
		public static int num = 0;
		//# of item in a single file
		public static int item_size = 500;
		public static boolean refreshAPI = true;
		//Set the current date and previous date
		public static ConcurrentHashMap<String,Integer> time_index = new ConcurrentHashMap<String,Integer>();
		public static ConcurrentHashMap<String,Boolean> time_finished = new ConcurrentHashMap<String,Boolean>();
		//record the index of file has been retrieved
		public static String Today;
		public static boolean init = true;%>


<%
	//Set refresh, autoload time as 60 seconds(2 min)
		response.setIntHeader("Refresh", 60);  		
		/*
		TimeLine;
	Get a list of dates for timeline
		*/
		SimpleDateFormat dateFormat = new SimpleDateFormat("MM-dd-yyyy");
		String todayDate = dateFormat.format(new Date());
		ArrayList<String> dates = new ArrayList<String>();
		Calendar cal = Calendar.getInstance();
		int today = cal.get(Calendar.DATE);
		if(!todayDate.equals(Today))
		{
	Today = todayDate;
	time_index.put(Today,0);
	time_finished.put(Today,false);
	refreshAPI = true;
		}
		else{
	refreshAPI = false;
		}
		/*
		* Timeline
		*/
  for(String start = "10-30-2014"; dateFormat.parse(start).compareTo(dateFormat.parse(Today)) <= 0 ; )
		{				
		//First initial one time
				if(init){
					time_index.put(start,0);	
			time_finished.put(start,false);
		}
	    dates.add(start);
		Calendar c = Calendar.getInstance();
		c.setTime(dateFormat.parse(start));
		c.add(Calendar.DATE, 1);  
		start = dateFormat.format(c.getTime()); 
		} 
		System.out.println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!=============");
		init = false;
		//By default
		String timeline = Today;
		String keyword = "All";
		
		String T = request.getParameter("timeline");
		String K = request.getParameter("keyword");
		System.out.println(K);
		System.out.println(T);
		if(T != null && K != null)
		{
	timeline = T;
	keyword = K;
		}

	   
	   AWSCredentials credentials = new PropertiesCredentials(DataFetch.class.getResourceAsStream("AwsCredentials.properties"));
		//sdb = new AmazonSimpleDBClient(credentials);
        AmazonSimpleDBClient newDb = new AmazonSimpleDBClient(credentials);
        
        SelectResult selectResult = null;
        String query = null;     
        query = "select Latitude, Longitude, keyword from " + "car" + " where keyword = '" + keyword + "' and Date = '" + timeline + "'";
        SelectRequest selectRequest = new SelectRequest(query);
        selectResult = newDb.select(selectRequest);
        List<Item> list = selectResult.getItems();
	   
	
		
  		// Get a list of predefined keyword
  	ArrayList<String> dropdownList = new ArrayList<String>();
  		//add ALL keywords
  		dropdownList.add("All");
  		//Top 10 keywords
  	//	Iterator<String> it = TwitterKeyword.sorted_tfidf.keySet().iterator();
  		//for(int i = 0 ; i < 10 && it.hasNext(); i++)
  		//{
  			//dropdownList.add(it.next());
  		//}
  		dropdownList.add("Columbia");
  		dropdownList.add("Computer");
  		dropdownList.add("Snow");
  		dropdownList.add("Baseball");
  		dropdownList.add("University");
%>

<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title>Twitt-Map</title>
<!-- External CSS -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="css/style3.css" />
<!-- External script -->
<script
	src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&libraries=visualization"></script>
<script type="text/javascript" src="js/markercluster.js"></script>
<script
	src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
<script src="js/bootstrap.js"></script>
<script>
	    		/**
	    			Get lat and lng from address
	    		*/
	   // 		function LocationGet(address)
	    //		{
    		//		var xmlHttp = null;
    			//    var Url = "https://maps.googleapis.com/maps/api/geocode/json?address="+encodeURIComponent(address)+"&sensor=false";
    			  //  xmlHttp = new XMLHttpRequest();
    			   // xmlHttp.open( "GET", theUrl, false );
    			   // xmlHttp.send( null );
    			    //return xmlHttp.responseText;
	    		//}
    </script>
<script>
   	/*  
    * Parse the location 
    * return the latlng data
    */ 
   
   	
	function ParseLocation()
    {
    	Location = new Array();
    	
		<%
	
	//	List<Entity> OldResults = MemCache.getFromCache(timeline);
		//if(!time_finished.get(timeline))
		//{
			//List<Entity> NewResults = TweetRetrive.fetchEntities(timeline);
			//if(OldResults == null)
			//{
				//if(NewResults!=null){
				//	OldResults = NewResults;
					//MemCache.storeToCache(timeline, OldResults);
				//}
			//}
		//	else{
			//	boolean equalLists = OldResults.size() == NewResults.size() && OldResults.containsAll(NewResults);
				//if(!equalLists)
				//{
					//OldResults = NewResults;
					//MemCache.storeToCache(timeline, OldResults);				
				//}
			//}
		//}
	//	if(OldResults!=null)
	//	{
			
			for(Item item : list) {
			//{
				//	String keyList = null;
					//if(t.getProperty("keyword")!=null)
					//{
						//keyList= t.getProperty("keyword").toString();
					//}
			//		if( keyword.equals("All") || (  keyList !=null && keyList.toLowerCase().indexOf(keyword.toLowerCase()) != -1))
				//	{
					//	Double longitude = null;
						//Double latitude = null;
						//if(t.getProperty("Longitude") !=null  && t.getProperty("Latitude") != null)
						//{
							//String lon = t.getProperty("Longitude").toString();
							//String lat = t.getProperty("Latitude").toString();
						
        			
        	System.out.println("====!!!!========="+item.getAttributes().get(0).getValue());
        	System.out.println("====!!!!========="+item.getAttributes().get(1).getValue());
        					Double latitude = null;
        					Double longitude = null;
							latitude = Double.parseDouble(item.getAttributes().get(0).getValue());
							longitude = Double.parseDouble(item.getAttributes().get(1).getValue());
				%>
							Location.push(new google.maps.LatLng(<%=latitude%>, <%=longitude%>));
				<%
        	}
		
					//	}
						//else
						//{
							//Find location by Place Name
						//	String address =  t.getProperty("location").toString();
						//	address = address.replace("\n", "");
				%>
							<%-- var address = "<%=address%>";
					    	var jsonResult = LocationGet(address);
					        var LatLng = JSON.parse(jsonResult);
					        if(LatLng.status == google.maps.GeocoderStatus.OK)
					        {
					        	Location.push(new google.maps.LatLng(LatLng.results[0].geometry.location.lat, LatLng.results[0].geometry.location.lng));
					        }
				<%	 --%>
						/*  }
					}
			}
		} */
	//	%>
		return Location;
	}
   	
	



    

     </script>
<script src="js/GoogleMapAPI.js"></script>
</head>

<body>
	<div id="sidebar">
		<!-- Logo -->
		<h1 id="logo">
			<a href="#">Twitter Map</a>
		</h1>

		<div style="margin-top: 20px;">
			<center>
				<Strong> TeamMember: <br> Qianyi Zhong<br> Weixin Wu
				</Strong>
			</center>
		</div>

		<!-- Nav -->
		<nav id="nav">
		<div style="margin-top: 20px;">
			<button class="btn btn-danger" onclick="hide()">Heatmap</button>
		</div>
		<div style="margin-top: 20px;">
			<button class="btn btn-danger" onclick="removeM()">Count</button>
		</div>
	<!-- 	<div id="but">
			<button class="btn btn-warning" onclick="removeM()">Markers</button>
		</div> -->
		
	
		<div id="but">
		
		<!-- 	<button type="button" class="btn btn-danger custom">
			<span class="glyphicon glyphicon-plus"></span>
		</button> -->
		
	<div id="but">
		<div class="btn-group">
			<button type="button" class="btn btn-primary custom">
				<span class="glyphicon glyphicon-time"></span>
			</button>

			<button type="button" class="btn btn-primary custom dropdown-toggle"
				data-toggle="dropdown">
				<span class=" caret"></span> <span class="sr-only">Toggle
					Dropdown</span>
			</button>
			<ul class="dropdown-menu " role="menu">
				<%
					for (String D : dates) {
				%>
				<li
					onClick="location.href='index.jsp?keyword=<%=keyword%>&timeline=<%=D%>'">
					<a href="#"> <span class="glyphicon glyphicon-star"></span><%=D%></a>
				</li>
				<%
					}
				%>
			</ul>
		</div>
		</div>
		<button type="button" style="margin-top: 10px"
			class="navbar-toggle custom" data-toggle="collapse"
			data-target=".navbar-collapse">
			<span class="sr-only">Toggle navigation</span> <span class="icon-bar"></span>
			<span class="icon-bar"></span> <span class="icon-bar"></span>
		</button>
	</div>
		<div id="but">

			<%
				if (keyword != null && !keyword.isEmpty()) {
			%>
			<button type="button margin-top:10px;" class="btn btn-info btn-sm">
				Keywords:<%=keyword%></button>
			<%
				} else {
			%>
			<button type="button" class="btn btn-success custom ">--ALL--</button>
			<%
				}
			%>
			<button type="button" class="btn btn-info btn-sm dropdown-toggle"
				data-toggle="dropdown">
				<span class=" caret"></span> <span class="sr-only">Toggle
					Dropdown</span>
			</button>
			<ul class="dropdown-menu" role="menu">
				<li class="disabled"><a href="#"></a></li>
				<li class="divider"></li>
				<%
					for (String word : dropdownList) {
						if (!word.equalsIgnoreCase(keyword)) {
				%>
				<li><a
					href="index.jsp?keyword=<%=word%>&timeline=<%=timeline%>"><%=word%></a></li>
				<%
					}
					}
				%>
			</ul>
		</div>
		
	
	</div>
	<br>
	
	<div style="background-color: white">
		<br>
		<div style="padding-top: 5px" id="map-canvas"></div>
	</div>
</body>
</html>
