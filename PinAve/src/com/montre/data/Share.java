package com.montre.data;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.ArrayList;

import twitter4j.Twitter;
import twitter4j.http.AccessToken;
import twitter4j.http.RequestToken;

import com.google.android.maps.GeoPoint;
import com.montre.lib.Const;
import com.montre.util.JsonParser;
import com.recipe.ifoodtv.facebook.Facebook;

import android.content.Context;
import android.content.SharedPreferences;
import android.location.Location;
import android.location.LocationManager;
import android.location.LocationProvider;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.widget.Toast;

public class Share {

	public static ArrayList<CategoryInfo> 	g_arrCategory;
	public static ArrayList<UserInfo>  		g_arrUsers;
	public static UserInfo					g_userInfo;

	public static CustomLocation my_location;
	public static CustomLocation my_Customlocation;
	
	
	public static double defaultLat = 37.785834;
	public static double defaultLng = -122.406417;
	
	
	static public String getCustomUserLocationAddress(){
	    if (my_Customlocation != null) {
	        return getAddress(my_Customlocation);
	    }
	    else {
	    	return getAddress(my_location);
	    }
	}


	public static String getStandardUserLocationAddress(){
	    
	    return getAddress(my_location);
	}

	private static String getAddress(CustomLocation location){
	    
		double lat, lng;
		if (location != null) {
			lat = location.getLatitude();
			lng = location.getLongitude();
		} else {
			if (Const.TEST_LOCATION) {
				lat = defaultLat;
				lng = defaultLng;
			} else {
				lat = location.getLatitude();
				lng = location.getLongitude();
			}
		}
		
		
	    String urlString = Utils.getAddressURLFromLocation(lat, lng);
	    
	    String result = JsonParser.getAddress(urlString);
	    return result;
	}

	public static CustomLocation getCoordinateByAddress (String address) {
		String urlString = Utils.getGoogleAddressUrl(address);
		
		ArrayList<String> result = JsonParser.getCoordinateByAddress(urlString);
	    
		if (result != null) {
			double lat = 0.0f;
			try {
				lat = Double.parseDouble(result.get(0));
			} catch (Exception e) {
				lat = 0.0f;
			}

			double lng = 0.0f;
			try {
				lng = Double.parseDouble(result.get(1));
			} catch (Exception e) {
				lng = 0.0f;
			}
			
			CustomLocation loc = new CustomLocation(lat, lng);
			
			return loc;
		}
		
		return null;
	}
	
	
	
}
