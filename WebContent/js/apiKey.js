/**
 *  For controlling the API key usage
 */
		Storage.prototype.setObj = function(key, obj) {
		    return this.setItem(key, JSON.stringify(obj));
		}
		Storage.prototype.getObj = function(key) {
		    return JSON.parse(this.getItem(key));
		}
   		var apiKey = [];
   		//API keys
		function initialkey(key,quota){
   			keyPair = [key,quota];
   			return keyPair;
   		}   		
	   <%
	   //Refresh the google api key usage?
   	   if(refreshAPI)
   	   {
   			for(String apikey : TweetRetrive.GoogleAPI)
   			{
	   %> 
				apiKey.push(initialkey("<%=apikey%>",2500));   					
	   <%
   			}
			refreshAPI = false;
			System.out.println("initialize api key");
	   %>
	   		sessionStorage.setObj("apiKey",apiKey);
	   <%
	   }
	   else
	   {
	   %>
			//From session storage retrive the api key
	   		if(sessionStorage.getObj("apiKey")){
				var tmp = sessionStorage.getObj("apiKey");			
				console.log(tmp.length);
				for(var i = 0; i < tmp.length ; i++)
				{
					console.log(tmp[i][0]+","+tmp[i][1]);
					apiKey.push(initialkey(tmp[i][0],Number(tmp[i][1])));	
				}
	   		}
	   <%
	   }
	   System.out.println("just before the seesionStorage.setObj...");
	   %>
		// Check the contents of the taxiData every second
	   console.log("just before the seesionStorage.setObj...");
	   
	   
		/**
			Find key with quota > 0
		*/
	    function FindKey()
	    {
	    	for(var i = 0 ; i < apiKey.length; i++)
	    	{
	    		if(apiKey[i][1] > 0)
	    		{
	    			apiKey[i][1]--;
	    			//console.log("key: "+apiKey[i][0]);
	    			sessionStorage.setObj("apiKey",apiKey);
	    			return apiKey[i][0];
	    		}
	    	}
	    	return null;
	    }
		/**
			Get lat and lng from address
		*/
		function LocationGet(address)
		{
				var xmlHttp = null;
			    var Url = "https://maps.googleapis.com/maps/api/geocode/json?address="+encodeURIComponent(address)+"&sensor=false&key=";
			    var key = FindKey();
			    if(key!=null)
		    	{
					var theUrl = Url + key;
		    	}
			    else{
			    	console.log("running out of keys");
			    }
				
			    xmlHttp = new XMLHttpRequest();
			    xmlHttp.open( "GET", theUrl, false );
			    xmlHttp.send( null );
			    
			    return xmlHttp.responseText;
		}
		