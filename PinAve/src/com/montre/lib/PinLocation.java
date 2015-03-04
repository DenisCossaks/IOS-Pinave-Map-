package com.montre.lib;

import org.json.JSONArray;
import org.json.JSONObject;

import com.montre.data.PinInfo;
import com.montre.util.XmlParser;


public class PinLocation {
	
	public static PinInfo GetAddress(double lat, double lng)
	{
		String url= String.format("http://maps.google.com/maps/geo?q=%f,%f&output=json", lat, lng);
		System.out.println("url = " + url);
		
		String strResult = XmlParser.getStringFromUrl(url);
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		try {
			JSONObject total = new JSONObject(strResult);
			JSONArray Placemark = total.optJSONArray("Placemark");
			
			if (Placemark != null) {
				
				for (int i = 0; i < Placemark.length(); i++) {
					
					PinInfo pinInfo = new PinInfo();
						
					JSONObject obj = Placemark.optJSONObject(i);
					
					String address = obj.optString("address");
					String str_address = address.substring(0, address.indexOf(","));
					
					JSONObject AddressDetails = obj.getJSONObject("AddressDetails");
					if(AddressDetails == null) 
						continue;
					
					JSONObject Country = AddressDetails.getJSONObject("Country");
					String str_country = Country.optString("CountryName");
					JSONObject AdministrativeArea = Country.getJSONObject("AdministrativeArea");
					
					String str_state = AdministrativeArea.optString("AdministrativeAreaName");
					JSONObject SubAdministrativeArea = null;
					String str_city = "";
					try {
						SubAdministrativeArea = AdministrativeArea.getJSONObject("SubAdministrativeArea");
					} catch (Exception e) {
						SubAdministrativeArea = null;
					}
					
					if (SubAdministrativeArea != null) {
						str_city = SubAdministrativeArea.optString("SubAdministrativeAreaName");
					} else {
						JSONObject Locality = AdministrativeArea.getJSONObject("Locality");
						str_city = Locality.optString("LocalityName");
					}
					if (str_city == null || str_city.equals("")) {
						str_city = str_state;
						str_state = "";
					}
					
					pinInfo.str_full_address = address;
					pinInfo.str_address = str_address;
					pinInfo.str_city = str_city;
					pinInfo.str_state = str_state;
					pinInfo.str_country = str_country;
					pinInfo.str_lat = String.valueOf(lat);
					pinInfo.str_lng = String.valueOf(lng);
					
					return pinInfo;
					
				}
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return null;
	}

}
