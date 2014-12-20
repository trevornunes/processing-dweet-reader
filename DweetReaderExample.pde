JSONObject jsonPayload;

String aThing="tbot-0";  // tbot-0 is our machine that is 'dweeting' happens to be my phone.
float az, pitch, roll, lat, lng, gx, gy, gz;  // What data is this thing producing ?         
int lastm; 

void setup() {
  thread("dweetUpdate");
}


// Thread spins once per second grabbing the payload and filling our local
// data. 
void dweetUpdate() 
{
  int dweet_grab = 0;

  while (true) {
    int m = millis();
    if (m - lastm > 1000) {  // flip dweet_grab 1,0,1,0,0... every second.
      lastm = m;
      dweet_grab =1;
    } else {
      dweet_grab =0;
    }
    // END OF THROTTLE

    if (dweet_grab == 1)
    {
      dweetCollect(aThing);
      try {
        if ( aThing == "tbot-0" ) {  // Change to whatever thing you wish to listen to.
          az = jsonPayload.getInt("az"); // Change to match whatever data it publishes e.g temperature etc.
          pitch = jsonPayload.getInt("pitch");
          roll = jsonPayload.getInt("roll");
          println("dweet.io/follow/" + aThing + "    az: " + az + " pitch: " + pitch + " roll: " + roll);
        }
      }
      catch(Exception e) {   
        // If we don't try/catch you'll see missed payload exceptions etc. plus the JSON data can change at any time ...
        println("failed to parse JSON payload or no data available");
      }

      try {
        if ( aThing == "tbot-0" ) {    
          //  Some dweets are not aggregated into a single payload, so we need another try/catch extract for GPS data.
          lat = jsonPayload.getFloat("lat");
          lng = jsonPayload.getFloat("long");
        }
      }
      catch(Exception e) {
      }
    }
  }
}


// dweet 'read'
void dweetCollect(String thing)
{ 
  JSONObject json;

  try {
    json = loadJSONObject("http://dweet.io/get/latest/dweet/for/" + thing );
    JSONArray values = json.getJSONArray("with");
    for ( int i = 0; i < values.size (); i++) {
      JSONObject  item = values.getJSONObject(i);
      String  theThing = item.getString("thing");        
      String   theDate = item.getString("created"); 
      jsonPayload = item.getJSONObject("content"); // extract just the content JSON
      println("dweetCollect(" +theThing +") " +theDate + jsonPayload);
    }
  }
  catch( Exception e ) {
    println("dweetCollect: failed for " + thing);
  }
}

