package com.montre.data;

import java.net.URLEncoder;
import java.util.ArrayList;

import com.google.android.maps.GeoPoint;
import com.montre.lib.Const;

import android.location.Location;

public class Utils {
		
	public static final String SERVER_URL = "http://pinave.com";
	public static final String CHAT_URL = "http://blazing-frost-9185.herokuapp.com";
	
	
	public static String getUrlEncoded(String strValue) {
		String strUrl = strValue;
		try {
			strUrl = URLEncoder.encode(strValue, "UTF-8");
			strUrl = strUrl.replaceAll("\\+", "%20");
		} catch (Exception e) {}
		return strUrl;
	}
	
	public static String getLoginUrl(String strUser, String strPW) {
		String result = String.format("%s/request/login?email=%s&password=%s", 
				SERVER_URL, getUrlEncoded(strUser), getUrlEncoded(strPW));
		
		System.out.println("login url = " + result);
		
		return result;
	}
	
	public static String getLogoutUrl(String strAuthCode) {
		return String.format("%s/request/logout/%s",
				SERVER_URL, getUrlEncoded(strAuthCode));
	}
	
	public static String getRegisterUrl(){
		return String.format("%s/request/reg", SERVER_URL);
	}
	
	
	public static String getCategoriesUrl() {
		return String.format("%s/request/categories", SERVER_URL);
	}
	
	public static String getUsersUrl() {
		String result = String.format("%s/request/users", SERVER_URL);
		System.out.println("getUsersUrl url = " + result);
		return result;
	}
	
	public static String getMyAvenueUrl()
	{
	    String auth_code = UserLoginInfo.getLoginCode();

		String result = String.format("%s/request/myavenue/%s", SERVER_URL, getUrlEncoded(auth_code));
		
		System.out.println("getMyAvenueUrl = " + result);
		
		return result;
	}

	public static String getMyPinCountUrl()
	{
	    String auth_code = UserLoginInfo.getLoginCode();

		String result = String.format("%s/request/private_uinfo/%s", SERVER_URL, getUrlEncoded(auth_code));
		
		System.out.println("getMyPinCountUrl = " + result);
		
		return result;
	}
	
	public static String getCountPinsUrl()
	{
	    String timezone = Setting.getTimezone();

	    float radius = Setting.getRadius();
	    
	    
	    if (Setting.getUnit() == Setting.UNIT_MILE) { // if mile
	        radius = (float) (radius * 1.613);
	    }
	    
	    String strCategory = "";
	    for (int i = 0; i < Share.g_arrCategory.size(); i++) {
			CategoryInfo category = Share.g_arrCategory.get(i);
			
			strCategory = String.format("%s&category[]=%s", strCategory, category.getId());
		}
	    
	    
	    double lat, lng;
	    
	    CustomLocation location;
	    if (Share.my_Customlocation != null) {
	        location = Share.my_Customlocation;
		    lat = location.getLatitude();
		    lng = location.getLongitude();
	    } else {
	        location = Share.my_location;

	        if (Const.TEST_LOCATION) {
	        	lat = Share.defaultLat;
	        	lng = Share.defaultLng;
	        } else {
	        	if (location == null) {
	        		lat = lng = 0.0;
	        	}
	        	else {
	    		    lat = location.getLatitude();
	    		    lng = location.getLongitude();
	        	}
	        }
	    }
	    
	    
	    
	    int pins = Setting.getNumberofPins();
	    
	    String urlString= String.format("%s/request/count?lat=%f&lng=%f&radius=%f&pins=%d&tz=%s%s",
	    		SERVER_URL,
	    		lat, lng, radius, pins,
	    		timezone, strCategory);

	    System.out.println("getCountPins url = " + urlString);
	    
	    return urlString;
	}
	
	public static String getUserPinsUrl(String user_id) {
		String urlString = String.format("%s/request/upins/%s", SERVER_URL, getUrlEncoded(user_id));
		
		System.out.println("getUserPinsUrl = " + urlString);
		return urlString;
	}
	
	
	public static String getPinsAroundUser(ArrayList<CategoryInfo> selectedCategory, int page , int limit)
	{
	    String timezone = Setting.getTimezone();

	    float radius = Setting.getRadius();
	    if (Setting.getUnit() == Setting.UNIT_MILE) { // if mile
	        radius = (float) (radius * 1.613);
	    }
	    
	    String strCategory = "";
	    for (int i = 0; i < selectedCategory.size(); i++) {
			CategoryInfo category = selectedCategory.get(i);
			
			if (category.getSelect())
				strCategory = String.format("%s&category[]=%s", strCategory, category.getId());
		}
	    
	    double lat, lng;
	    
	    CustomLocation location;
	    if (Share.my_Customlocation != null) {
	        location = Share.my_Customlocation;
		    lat = location.getLatitude();
		    lng = location.getLongitude();
	    } else {
	        location = Share.my_location;

	        if (Const.TEST_LOCATION) {
	        	lat = Share.defaultLat;
	        	lng = Share.defaultLng;
	        } else {
	        	if (location == null) {
	        		lat = lng = 0.0;
	        	}
	        	else {
	    		    lat = location.getLatitude();
	    		    lng = location.getLongitude();
	        	}
	        }
	    }
	    
	    
	    int pins = Setting.getNumberofPins();
	    
	    String urlString= String.format("%s/request/all_pins?lat=%f&lng=%f&radius=%f&pins=%d&tz=%s&pg=%d&limit=%d%s",
	    		SERVER_URL,
	    		lat, lng, radius, pins, timezone,
	    		page, limit,
	    		strCategory);

	    System.out.println("getPinAroundUser url = " + urlString);
	    
	    return urlString;
	}
	
	
	public static String getPinsAroundUserForNotify(ArrayList<CategoryInfo> selectedCategory)
	{
	    String timezone = Setting.getTimezone();

	    float radius = Notification.getDistance();
	    if (Setting.getUnit() == Setting.UNIT_MILE) { // if mile
	        radius = (float) (radius * 1.613);
	    }
	    
	    String strCategory = "";
	    for (int i = 0; i < selectedCategory.size(); i++) {
			CategoryInfo category = selectedCategory.get(i);
			
			if (category.getSelect())
				strCategory = String.format("%s&category[]=%s", strCategory, category.getId());
		}
	    
	    
	    double lat, lng;
	    
	    CustomLocation location;
	    if (Share.my_Customlocation != null) {
	        location = Share.my_Customlocation;
		    lat = location.getLatitude();
		    lng = location.getLongitude();
	    } else {
	        location = Share.my_location;

	        if (Const.TEST_LOCATION) {
	        	lat = Share.defaultLat;
	        	lng = Share.defaultLng;
	        } else {
	        	if (location == null) {
	        		lat = lng = 0.0;
	        	}
	        	else {
	    		    lat = location.getLatitude();
	    		    lng = location.getLongitude();
	        	}
	        }
	    }
	    
	    int pins = Setting.getNumberofPins();
	    
	    String urlString= String.format("%s/request/all_pins?lat=%f&lng=%f&radius=%f&pins=%d&tz=%s%s",
	    		SERVER_URL,
	    		lat, lng, radius, pins, timezone,
	    		strCategory);

	    System.out.println("getPinsAroundUserForNotify url = " + urlString);
	    
	    return urlString;
	}
	
	public static String getSearchPinsUrl(ArrayList<CategoryInfo> selectedCategory, String search)
	{
	    String timezone = Setting.getTimezone();

	    float radius = Setting.getRadius();
	    if (Setting.getUnit() == Setting.UNIT_MILE) { // if mile
	        radius = (float) (radius * 1.613);
	    }
	    
	    String strCategory = "";
	    for (int i = 0; i < selectedCategory.size(); i++) {
			CategoryInfo category = selectedCategory.get(i);
			
			if (category.getSelect())
				strCategory = String.format("%s&category[]=%s", strCategory, category.getId());
		}
	    
	    double lat, lng;
	    
	    CustomLocation location;
	    if (Share.my_Customlocation != null) {
	        location = Share.my_Customlocation;
		    lat = location.getLatitude();
		    lng = location.getLongitude();
	    } else {
	        location = Share.my_location;

	        if (Const.TEST_LOCATION) {
	        	lat = Share.defaultLat;
	        	lng = Share.defaultLng;
	        } else {
	        	if (location == null) {
	        		lat = lng = 0.0;
	        	}
	        	else {
	    		    lat = location.getLatitude();
	    		    lng = location.getLongitude();
	        	}
	        }
	    }
	    
	    int pins = Setting.getNumberofPins();
	    
	    String urlString= String.format("%s/request/all_pins?search=%s&lat=%f&lng=%f&radius=%f&pins=%d&tz=%s%s",
	    		SERVER_URL,
	    		search,
	    		lat, lng, radius, pins, timezone,
	    		strCategory);

	    System.out.println("getSearchPinsUrl = " + urlString);
	    
	    return urlString;
	}
	
	public static String getPinAroundRouteUrl(ArrayList<CustomLocation> locations)
	{

	    String strCategory = "";
	    for (int i = 0; i < Share.g_arrCategory.size(); i++) {
			CategoryInfo category = Share.g_arrCategory.get(i);
			
			strCategory = getUrlEncoded(String.format("%s&category[]=%s", strCategory, category.getId()));
		}

	    String strLocations = "";
	    for (int i = 0; i < locations.size(); i++) {
	    	strLocations = getUrlEncoded(String.format("%s&latlng[]=%f,%f", strLocations, locations.get(i).getLatitude(), locations.get(i).getLongitude()));
		}
	    
	    int radius = 1;
	    
	    String urlString= String.format("%s/request/route_pins?search=\"\"%s%s&radius=%d",
	    		SERVER_URL,
	    		strCategory, strLocations, radius);

	    System.out.println("getPinAroundRouteUrl url = " + urlString);
	    
	    return urlString;
	}
	
	public static String getAddressURLFromLocation(double latitude, double longitude){
		String urlString= String.format("http://maps.google.com/maps/geo?q=%f,%f&output=json",
	    		latitude, longitude);
		
		System.out.println("getAddressURLFromLocation url = " + urlString);
		
	    return urlString;
	}
	public static String getSearchURLFromText(String searchText){
		
		String urlString= String.format("http://maps.google.com/maps/geo?q=%s&output=json",	getUrlEncoded(searchText));
		
		System.out.println("getSearchURLFromText url = " + urlString);
		
	    return urlString;
	}
	public static String getGoogleAddressUrl(String address) {
		return String.format("http://maps.google.com/maps/geo?q=%s&output=csv", getUrlEncoded(address));
	}
	
	public static String getGoogleRouteUrl(CustomLocation start, CustomLocation end, int mode) {
		String url = "http://maps.googleapis.com/maps/api/directions/json?";
		
		url += String.format("origin=%f,%f", start.getLatitude(), start.getLongitude());
		url += String.format("&destination=%f,%f", end.getLatitude(), end.getLongitude());
		
		if (mode == 2) {
			url += "&mode=walking";
		} else if (mode == 1) {
			url += "&mode=bicycling";
		} 
		
		url += "&sensor=false";
		
		System.out.println("getGoogleRouteUrl = " + url);

		return url;
	}
	
	
	public static String getRatingUrl(String pinId){
		String urlString= String.format("%s/request/votes/%s", SERVER_URL, pinId);
		
		System.out.println("getRatingUrl url = " + urlString);
		
	    return urlString;
	}
	public static String postRatingUrl(String user_code, String pinId, int rate){
		String urlString= String.format("%s/request/vote/%s?pin=%s&rate=%d", SERVER_URL, user_code, pinId, rate);
		
		System.out.println("postRatingUrl url = " + urlString);
		
	    return urlString;
	}
	
	public static String isAvenuePinUrl(String user_code, String pinId){
		String urlString= String.format("%s/request/is_bookmark/%s/?pin=%s", SERVER_URL, user_code, pinId);
		
		System.out.println("isAvenuePinUrl url = " + urlString);
		
	    return urlString;
	}
	public static String postAdd_RemovePinUrl(String user_code, String pinId){
		String urlString= String.format("%s/request/bookmark/%s/?pin=%s", SERVER_URL, user_code, pinId);
		
		System.out.println("postAdd_RemovePinUrl url = " + urlString);
		
	    return urlString;
	}
	
	public static String isAvenueUserUrl(String user_code, String userId){
		String urlString= String.format("%s/request/is_friend/%s/?user=%s", SERVER_URL, user_code, userId);
		
		System.out.println("isAvenueUserUrl url = " + urlString);
		
	    return urlString;
	}
	public static String postAddUserUrl(String user_code, String userId){
		String urlString= String.format("%s/request/add_avenue/%s/?user=%s", SERVER_URL, user_code, userId);
		
		System.out.println("postAddUserUrl url = " + urlString);
		
	    return urlString;
	}
	public static String postRemoveUserUrl(String user_code, String userId){
		String urlString= String.format("%s/request/delete_avenue/%s/?user=%s", SERVER_URL, user_code, userId);
		
		System.out.println("postRemoveUserUrl url = " + urlString);
		
	    return urlString;
	}
	public static String getDeletePinUrl(String user_code, String pinId){
		String urlString= String.format("%s/request/delete_pin/%s/?pin=%s", SERVER_URL, user_code, pinId);
		
		System.out.println("getDeletePinUrl url = " + urlString);
		
	    return urlString;
	}
	public static String isReviewedUrl(String user_code, String pinId){
		String urlString= String.format("%s/request/voted/%s/?pin=%s", SERVER_URL, user_code, pinId);
		
		System.out.println("isReviewedUrl url = " + urlString);
		
	    return urlString;
	}
	
	public static String getReviewsUrl(String pinId){
		String urlString= String.format("%s/comments/%s.json", CHAT_URL, pinId);
		
		System.out.println("getReviewsUrl url = " + urlString);
		
	    return urlString;
	}
	
	public static String postReviewsUrl(){
		String urlString= String.format("%s/messages/comment.json", CHAT_URL);
		
	    return urlString;
	}
	public static String postSendMessageUrl(String user_code){
		String urlString= String.format("%s/request/mail/%s", CHAT_URL, user_code);
		
	    return urlString;
	}
	
	public static String postUpdateProfileUrl(){
		String urlString= String.format("%s/request/update", SERVER_URL);
		
	    return urlString;
	}
	
	public static String postPlacePinUrl(){
		String urlString= String.format("%s/request/place_pin", SERVER_URL);
		
	    return urlString;
	}
	
	public static String postGetPinsRouterUrl(){
		String urlString= String.format("%s/request/route_pins", SERVER_URL);
		
	    return urlString;
	}
	

}
