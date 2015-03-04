package com.montre.util;

import java.util.ArrayList;
import java.util.Hashtable;

import org.json.JSONArray;
import org.json.JSONObject;

import android.location.Location;

import com.google.android.maps.GeoPoint;
import com.montre.data.CategoryInfo;
import com.montre.data.CustomLocation;
import com.montre.data.PinInfo;
import com.montre.data.ReviewInfo;
import com.montre.data.Share;
import com.montre.data.UserInfo;
import com.montre.data.Utils;
import com.montre.lib.Const;


public class JsonParser {
	
	public static ArrayList<String> getUserLogin(String strUserName, String strPassword) {
		String strResult = XmlParser.getStringFromUrl(Utils.getLoginUrl(strUserName, strPassword));
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		ArrayList<String> data = new ArrayList<String>();
		try {
			JSONObject total = new JSONObject(strResult);
			
			String message = total.optString("message");
			if (message.equalsIgnoreCase("ok")) {
				data.add(total.optString("message"));
				data.add(total.optString("code"));
				data.add(total.optString("user_id"));
			} 
			else {
				data.add(total.optString("message"));
			}
		} catch (Exception e) {}
		
		return data;
	}

	public static ArrayList<CategoryInfo> getCategories() {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getCategoriesUrl());
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		ArrayList<CategoryInfo> array = new ArrayList<CategoryInfo>();
		try {
			JSONObject total = new JSONObject(strResult);
			JSONObject categories = total.optJSONObject("categories");

			if ( categories != null ) {
				int j = 0;
				for (int i = 1; i <= 14; i++) {
					j = i;
					if (i == 13) j = 999;
					if (i == 14) j = 1000;
					
					
					JSONObject obj = categories.optJSONObject(String.valueOf(j));
					if (obj != null) {
						CategoryInfo data = new CategoryInfo();
						
						System.out.println(obj.optString("id") + " : " + obj.optString("name"));
						
						data.strId 		= getParsingString(obj.optString("id"));
						data.strName 	= getParsingString(obj.optString("name"));
						data.strSlug 	= getParsingString(obj.optString("slug"));
						data.strDescription = getParsingString(obj.optString("description"));
						data.strDaily 	= getParsingString(obj.optString("daily"));
						data.strIcon 	= getParsingString(obj.optString("icon"));
						
						array.add(data);
					}
				}
				
//				JSONObject obj = categories.optJSONObject(String.valueOf(i));
//				while ( obj != null ) {
//					CategoryInfo data = new CategoryInfo();
//					
//					System.out.println(obj.optString("id") + " : " + obj.optString("name"));
//					
//					data.strId 		= getParsingString(obj.optString("id"));
//					data.strName 	= getParsingString(obj.optString("name"));
//					data.strSlug 	= getParsingString(obj.optString("slug"));
//					data.strDescription = getParsingString(obj.optString("description"));
//					data.strDaily 	= getParsingString(obj.optString("daily"));
//					data.strIcon 	= getParsingString(obj.optString("icon"));
//					
//					array.add(data);
//					
//					i++;
//					obj = categories.optJSONObject(String.valueOf(i));
//				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return array;
		
	}
	
	public static ArrayList<UserInfo> getUsers() {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getUsersUrl());
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		ArrayList<UserInfo> array = new ArrayList<UserInfo>();
		try {
			JSONObject total = new JSONObject(strResult);
			JSONArray users = total.optJSONArray("users");

			if ( users != null ) {
				for (int i = 0 ; i < users.length() ; i ++) {
					JSONObject obj = users.getJSONObject(i);
					
					if (obj != null) {
						UserInfo data = new UserInfo();
						
						data.str_id 		= getParsingString(obj.optString("id"));
						data.str_firstname	= getParsingString(obj.optString("firstname"));
						data.str_lastname	= getParsingString(obj.optString("lastname"));
						data.str_fb			= getParsingString(obj.optString("fb"));
						data.str_code		= getParsingString(obj.optString("code"));
						data.str_chatcode	= getParsingString(obj.optString("chatcode"));
						data.str_chat_id	= getParsingString(obj.optString("chat_id"));
						data.str_public_code= getParsingString(obj.optString("public_code"));
						data.str_remindcode	= getParsingString(obj.optString("remindcode"));
						data.str_logins		= getParsingString(obj.optString("logins"));
						data.str_last_login	= getParsingString(obj.optString("last_login"));
						data.str_blocked	= getParsingString(obj.optString("blocked"));
						data.str_last_activity = getParsingString(obj.optString("last_activity"));
						data.str_daily		= getParsingString(obj.optString("daily"));
						data.str_created	= getParsingString(obj.optString("created"));
						
						JSONObject objDetail = obj.getJSONObject("detail");
						data.str_detail_id 	= getParsingString(objDetail.optString("id"));
						data.str_detail_user_id = getParsingString(objDetail.optString("user_id"));
						data.str_detail_birthday = getParsingString(objDetail.optString("birthday"));
						data.str_detail_gender	 = getParsingString(objDetail.optString("gender"));
						data.str_detail_phone	 = getParsingString(objDetail.optString("phone"));
						data.str_detail_city	 = getParsingString(objDetail.optString("city"));
						data.str_detail_state	 = getParsingString(objDetail.optString("state"));
						data.str_detail_country	 = getParsingString(objDetail.optString("country"));
						data.str_detail_timezone = getParsingString(objDetail.optString("timezone"));
						
						array.add(data);
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return array;
		
	}
	
	public static ArrayList<CategoryInfo> getPinCount() {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getCountPinsUrl());
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		ArrayList<CategoryInfo> array = new ArrayList<CategoryInfo>();
		try {
			JSONObject total = new JSONObject(strResult);
			JSONObject categories = total.optJSONObject("categories");

			if ( categories != null ) {
				int j = 0;
				for (int i = 1; i <= 14; i++) {
					j = i;
					if (i == 13) j = 999;
					if (i == 14) j = 1000;
					
					
					JSONObject obj = categories.optJSONObject(String.valueOf(j));
					if (obj != null) {
						CategoryInfo data = new CategoryInfo();
						
						System.out.println(obj.optString("id") + " : " + obj.optString("name"));
						
						data.strName 	= getParsingString(obj.optString("name"));
						try {
							data.pinNumber  = Integer.parseInt(getParsingString(obj.optString("pins_count")));
						} catch (Exception e) {
							data.pinNumber	= 0;
						}
						
						array.add(data);
					}
				}
				
//				JSONObject obj = categories.optJSONObject(String.valueOf(i));
//				while ( obj != null ) {
//					CategoryInfo data = new CategoryInfo();
//					data.strName 	= getParsingString(obj.optString("name"));
//					try {
//						data.pinNumber  = Integer.parseInt(getParsingString(obj.optString("pins_count")));
//					} catch (Exception e) {
//						data.pinNumber	= 0;
//					}
//					
//					array.add(data);
//					
//					i++;
//					obj = categories.optJSONObject(String.valueOf(i));
//				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return array;
	}
	
	public static String getMyPinCount() {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getMyPinCountUrl());
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		try {
			JSONObject total = new JSONObject(strResult);
			
			String message = total.optString("message");
			if (!message.equalsIgnoreCase("OK")) {
				return null;
			}
			
			
			JSONObject user = total.optJSONObject("user");

			if ( user != null ) {
				String pinCount = user.optString("pins_count");
				return pinCount;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return null;
	}
	
	
	public static Hashtable<String, Object> getGoogleRoute(CustomLocation origin, CustomLocation des, int mode) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getGoogleRouteUrl(origin, des, mode));
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		Hashtable<String, Object> data = new Hashtable<String, Object>();
		
		try {
			JSONObject total = new JSONObject(strResult);
			
			String status = total.optString("status");
			if (!status.equalsIgnoreCase("OK"))
				return null;
				
				
			JSONArray routes = total.optJSONArray("routes");
			
			if (routes != null) {
				JSONObject obj = routes.getJSONObject(0);
				
				JSONObject leg = obj.getJSONArray("legs").getJSONObject(0);
				
				JSONArray steps = leg.getJSONArray("steps");
				
				ArrayList<CustomLocation> polyLines = new ArrayList<CustomLocation>();
				
				for (int i = 0 ; i < steps.length() ; i ++) {
					JSONObject point = steps.getJSONObject(i);
					
					if (point != null) {
						if (i == 0) {
							JSONObject start = point.getJSONObject("start_location");
							String strLat = start.optString("lat");
							String strLng = start.optString("lng");
							
							polyLines.add(new CustomLocation(Const.toFloat(strLat), Const.toFloat(strLng)));
						}
						
						JSONObject end = point.getJSONObject("end_location");
						String strLat = end.optString("lat");
						String strLng = end.optString("lng");
						
						polyLines.add(new CustomLocation(Const.toFloat(strLat), Const.toFloat(strLng)));
					}
				}
				data.put("lines", polyLines);
				
/*				
				String points = obj.optJSONObject("overview_polyline").optString("points");
				
				String encoded = points.replaceAll("\\\\", "\\");
				
				ArrayList<GeoPoint> polyLines = new ArrayList<GeoPoint>();
				
				int len = points.length();
				int index = 0;
				
				int lat = 0, lng = 0;
				
				while (index < len) {
					int b;
					int shift = 0;
					int result = 0;
					
					do {
						b = encoded.charAt(index ++) - 63;
						
						result |= (b & 0x1f) << shift;
						shift += 5;
					} while (b >= 0x20);
					
					int dlat = (result & 1) == 1 ? ~(result >> 1) : (result >> 1);
					lat += dlat;
					
					shift = 0;
					result = 0;
					do {
						b = encoded.charAt(index ++) - 63;
						
						result |= (b & 0x1f) << shift;
						shift += 5;
					} while (b >= 0x20);
					
					int dlng = (result & 1) == 1 ? ~(result >> 1) : (result >> 1);
					lng += dlng;
					
					GeoPoint loc = new GeoPoint(lat, lng);
					polyLines.add(loc);
				}
				
				data.put("lines", polyLines);
*/
				////////// distance
				String distance	= leg.optJSONObject("distance").optString("value");
				data.put("distance", distance);
				
				String duration = leg.optJSONObject("duration").optString("text");
				data.put("duration", duration);

				PinInfo startPin = new PinInfo();
				startPin.str_full_address = leg.optString("start_address");
				startPin.str_lat = leg.optJSONObject("start_location").optString("lat");
				startPin.str_lng = leg.optJSONObject("start_location").optString("lng");
				data.put("start_point", startPin);
				
				PinInfo endPin = new PinInfo();
				endPin.str_full_address = leg.optString("end_address");
				endPin.str_lat = leg.optJSONObject("end_location").optString("lat");
				endPin.str_lng = leg.optJSONObject("end_location").optString("lng");
				data.put("end_point", endPin);

				return data;
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return null;
	}
	
	public static ArrayList<PinInfo> getUserPins(String userId) {
		String strResult = XmlParser.getStringFromUrl(Utils.getUserPinsUrl(userId));
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		ArrayList<PinInfo> data = new ArrayList<PinInfo>();
		try {
			JSONObject total = new JSONObject(strResult);
			JSONObject categories = total.optJSONObject("categories");
			
			if (Share.g_arrCategory != null) {
				int nCount = Share.g_arrCategory.size();
				for ( int i = 0; i < nCount; ++i ) {
					JSONObject category = categories.optJSONObject(Share.g_arrCategory.get(i).strId);
					if ( category != null ) {
						JSONArray pins = category.optJSONArray("pins");
						if ( pins != null ) {
							int nPinCount = pins.length();
							for ( int j = 0; j < nPinCount; ++j ) {
								JSONObject obj = pins.optJSONObject(j);
								
								PinInfo info = new PinInfo();
								
								info.str_id 	= obj.optString("id");
								info.str_url 	= obj.optString("url");
								info.str_title 	= obj.optString("title");
								info.str_slug 	= obj.optString("slug");
								info.str_image 	= obj.optString("image");
								info.str_country = obj.optString("country");
								info.str_state 	= obj.optString("state");
								info.str_city 	= obj.optString("city");
								info.str_address= obj.optString("address");
								info.str_user_id 	= obj.optString("user_id");
								info.str_phone = obj.optString("phone");
								info.str_lat = obj.optString("lat");
								info.str_lng = obj.optString("lng");
								info.str_category_id = obj.optString("category_id");
								info.str_description = obj.optString("description");
								info.str_expire_in = obj.optString("expire_in");
								info.str_edit = obj.optString("edit");
								info.str_author = obj.optString("author");
								
								// full address
								info.str_full_address = info.str_address + " " + info.str_city + " " + info.str_country;
				                    
								data.add(info);
							}
						}
					}
				}
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return data;
	}
	
	
	
	public static ArrayList<PinInfo> getPinsAroundUser(ArrayList<CategoryInfo> selected, int curPage, int limit) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getPinsAroundUser(selected, curPage, limit));
	
		ArrayList<PinInfo> result = getPins(strResult);
		
		return result;
	}
	
	public static ArrayList<PinInfo> getPinsAroundUser(ArrayList<CategoryInfo> selected) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getPinsAroundUserForNotify(selected));
	
		ArrayList<PinInfo> result = getPins(strResult);
		
		return result;
	}
	
	
	
	private static ArrayList<PinInfo> getPins(String strResult) {
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		ArrayList<PinInfo> data = new ArrayList<PinInfo>();
		try {
			JSONObject total = new JSONObject(strResult);
			JSONObject categories = total.optJSONObject("categories");
			
			if (Share.g_arrCategory != null) {
				int nCount = Share.g_arrCategory.size();
				for ( int i = 0; i < nCount; ++i ) {
					JSONObject category = categories.optJSONObject(Share.g_arrCategory.get(i).strId);
					if ( category != null ) {
						JSONArray pins = category.optJSONArray("pins");
						if ( pins != null ) {
							int nPinCount = pins.length();
							for ( int j = 0; j < nPinCount; ++j ) {
								JSONObject obj = pins.optJSONObject(j);
								
								PinInfo info = new PinInfo();
								
								info.str_id 	= obj.optString("id");
								info.str_url 	= obj.optString("url");
								info.str_title 	= obj.optString("title");
								info.str_slug 	= obj.optString("slug");
								info.str_image 	= obj.optString("image");
								info.str_country = obj.optString("country");
								info.str_state 	= obj.optString("state");
								info.str_city 	= obj.optString("city");
								info.str_address= obj.optString("address");
								info.str_user_id 	= obj.optString("user_id");
								info.str_phone = obj.optString("phone");
								info.str_lat = obj.optString("lat");
								info.str_lng = obj.optString("lng");
								info.str_category_id = obj.optString("category_id");
								info.str_description = obj.optString("description");
								info.str_expire_in = obj.optString("expire_in");
								info.str_edit = obj.optString("edit");
								info.str_author = obj.optString("author");
								
								// full address
								info.str_full_address = info.str_address + " " + info.str_city + " " + info.str_country;
				                    
								data.add(info);
							}
						}
					}
				}
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return data;
	}
	
	public static ArrayList<PinInfo> getPinAroundRoute(String strResult) {
		
		try {
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		ArrayList<PinInfo> data = new ArrayList<PinInfo>();
		try {
			JSONObject total = new JSONObject(strResult);
			JSONObject categories = total.optJSONObject("categories");
			
			if (Share.g_arrCategory != null) {
				int nCount = Share.g_arrCategory.size();
				for ( int i = 0; i < nCount; ++i ) {
					JSONObject category = categories.optJSONObject(Share.g_arrCategory.get(i).strId);
					if ( category != null ) {
						JSONArray pins = category.optJSONArray("pins");
						if ( pins != null ) {
							int nPinCount = pins.length();
							for ( int j = 0; j < nPinCount; ++j ) {
								JSONObject obj = pins.optJSONObject(j);
								
								PinInfo info = new PinInfo();
								
								info.str_id 	= obj.optString("id");
								info.str_url 	= obj.optString("url");
								info.str_title 	= obj.optString("title");
								info.str_slug 	= obj.optString("slug");
								info.str_image 	= obj.optString("image");
								info.str_country = obj.optString("country");
								info.str_state 	= obj.optString("state");
								info.str_city 	= obj.optString("city");
								info.str_address= obj.optString("address");
								info.str_user_id 	= obj.optString("user_id");
								info.str_phone = obj.optString("phone");
								info.str_lat = obj.optString("lat");
								info.str_lng = obj.optString("lng");
								info.str_category_id = obj.optString("category_id");
								info.str_description = obj.optString("description");
								info.str_expire_in = obj.optString("expire_in");
								info.str_edit = obj.optString("edit");
								info.str_author = obj.optString("author");
								
								// full address
								info.str_full_address = info.str_address + " " + info.str_city + " " + info.str_country;
				                    
								data.add(info);
							}
						}
					}
				}
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return data;
		
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public static ArrayList<PinInfo> getSearchPins(ArrayList<CategoryInfo> selected, String search) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getSearchPinsUrl(selected, search));
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		ArrayList<PinInfo> data = new ArrayList<PinInfo>();
		try {
			JSONObject total = new JSONObject(strResult);
			JSONObject categories = total.optJSONObject("categories");
			
			if (Share.g_arrCategory != null) {
				int nCount = Share.g_arrCategory.size();
				for ( int i = 0; i < nCount; ++i ) {
					JSONObject category = categories.optJSONObject(Share.g_arrCategory.get(i).strId);
					if ( category != null ) {
						JSONArray pins = category.optJSONArray("pins");
						if ( pins != null ) {
							int nPinCount = pins.length();
							for ( int j = 0; j < nPinCount; ++j ) {
								JSONObject obj = pins.optJSONObject(j);
								
								PinInfo info = new PinInfo();
								
								info.str_id 	= obj.optString("id");
								info.str_url 	= obj.optString("url");
								info.str_title 	= obj.optString("title");
								info.str_slug 	= obj.optString("slug");
								info.str_image 	= obj.optString("image");
								info.str_country = obj.optString("country");
								info.str_state 	= obj.optString("state");
								info.str_city 	= obj.optString("city");
								info.str_address= obj.optString("address");
								info.str_user_id 	= obj.optString("user_id");
								info.str_phone = obj.optString("phone");
								info.str_lat = obj.optString("lat");
								info.str_lng = obj.optString("lng");
								info.str_category_id = obj.optString("category_id");
								info.str_description = obj.optString("description");
								info.str_expire_in = obj.optString("expire_in");
								info.str_edit = obj.optString("edit");
								info.str_author = obj.optString("author");
								
								// full address
								info.str_full_address = info.str_address + " " + info.str_city + " " + info.str_country;
				                    
								data.add(info);
							}
						}
					}
				}
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return data;
	}
	
	public static String getAddress(String url) {
		
		String strResult = XmlParser.getStringFromUrl(url);
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		try {
			JSONObject total = new JSONObject(strResult);
			JSONArray Placemark = total.optJSONArray("Placemark");
			
			if (Placemark != null) {
				JSONObject obj = Placemark.optJSONObject(0);
				
				String address = obj.optString("address");
				
				return address;
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return "user location can not find";
	}
	
	public static ArrayList<CustomLocation> getAddressFromText(String text) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getSearchURLFromText(text));
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		try {
			JSONObject total = new JSONObject(strResult);
			JSONArray Placemark = total.optJSONArray("Placemark");
			
			if (Placemark != null) {
				
				ArrayList<CustomLocation> data = new ArrayList<CustomLocation>();
				
				for (int i = 0; i < Placemark.length(); i++) {
					JSONObject obj = Placemark.optJSONObject(i);
				
					
					String title = obj.optString("address");
					
					
					JSONArray coordinates = obj.getJSONObject("Point").getJSONArray("coordinates");
					
					double lat = Const.toDouble(coordinates.getString(1));
					double lng = Const.toDouble(coordinates.getString(0));
					
					CustomLocation loc = new CustomLocation(lat, lng);
					loc.setTitle(title);
					
					data.add(loc);
				}
				
				return data;
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return null;
	}
	
	public static ArrayList<String> getCoordinateByAddress(String url) {
		
		String strResult = XmlParser.getStringFromUrl(url);
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		try {
			String[] result = strResult.split(",");
			
			if (result[0].equals("200")) {
				ArrayList<String> arr = new ArrayList<String>();
				arr.add(0, result[2]);
				arr.add(1, result[3]);
				
				return arr;
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return null;
	}
	
	
	public static ArrayList<String> getRating(String pinId) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getRatingUrl(pinId));
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		try {
			JSONObject obj = new JSONObject(strResult);
			
			if (obj != null) {
				ArrayList<String> data = new ArrayList<String>();
				String str = obj.optString("message"); 
				data.add(str);
				str = obj.optString("rating");
				data.add(str);
				str = obj.optString("votes");
				data.add(str);
				
				return data;
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return null;
	}
	
	public static String isAvenuePin(String userCode, String pinId) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.isAvenuePinUrl(userCode, pinId));
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		try {
			JSONObject obj = new JSONObject(strResult);
			
			if (obj != null) {
				return obj.optString("message");
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return "";
	}
	
	public static String isAvenueUser(String userCode, String userId) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.isAvenueUserUrl(userCode, userId));
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		try {
			JSONObject obj = new JSONObject(strResult);
			
			if (obj != null) {
				return obj.optString("message");
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return "";
	}
	
	public static String addUserMyAvenue(String userCode, String userId) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.postAddUserUrl(userCode, userId));
		
		if ( strResult == null || strResult.length() == 0 )
			return "";
		
		try {
			JSONObject obj = new JSONObject(strResult);
			
			if (obj != null) {
				return obj.optString("message");
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return "";
	}
	public static String delUserMyAvenue(String userCode, String userId) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.postRemoveUserUrl(userCode, userId));
		
		if ( strResult == null || strResult.length() == 0 )
			return "";
		
		try {
			JSONObject obj = new JSONObject(strResult);
			
			if (obj != null) {
				return obj.optString("message");
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return "";
	}
	
	public static String postAdd_RemovePinUrl(String userCode, String pinId) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.postAdd_RemovePinUrl(userCode, pinId));
		
		if ( strResult == null || strResult.length() == 0 )
			return "";
		
		try {
			JSONObject obj = new JSONObject(strResult);
			
			if (obj != null) {
				return obj.optString("message");
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return "";
	}
	
	public static String getDeleteUserPin(String userCode, String pinId) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getDeletePinUrl(userCode, pinId));
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		try {
			JSONObject obj = new JSONObject(strResult);
			
			if (obj != null) {
				return obj.optString("message");
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return "";
	}
	
	
	
	public static String isReviewed(String userCode, String pinId) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.isReviewedUrl(userCode, pinId));
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		try {
			JSONObject obj = new JSONObject(strResult);
			
			if (obj != null) {
				return obj.optString("message");
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return "";
	}
	
	public static ArrayList<ReviewInfo> getReviews(String pinId) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getReviewsUrl(pinId));
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		try {
			JSONArray total = new JSONArray(strResult);
			
			if (total != null) {
				ArrayList<ReviewInfo> data = new ArrayList<ReviewInfo>();
				for (int i = 0; i < total.length(); i++) {
					JSONObject obj = total.optJSONObject(i);
					
					ReviewInfo info = new ReviewInfo();
					
					info.strUserName = obj.optJSONObject("user").optString("first_name") + " " + obj.optJSONObject("user").optString("last_name");
					info.strDate = obj.optString("updated_at");
					info.strMessage = obj.optString("message");
					
					data.add(info);
				}
				
				return data;
				
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return null;
	}
	
	public static ArrayList<String> postReview(String strUserName, String strPassword) {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getLoginUrl(strUserName, strPassword));
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		ArrayList<String> data = new ArrayList<String>();
		try {
			JSONObject total = new JSONObject(strResult);
			data.add(total.optString("message"));
			data.add(total.optString("code"));
			data.add(total.optString("user_id"));
		} catch (Exception e) {}
		
		return data;
	}

	
	public static Hashtable<String, Object> getMyAvenueList() {
		
		String strResult = XmlParser.getStringFromUrl(Utils.getMyAvenueUrl());
		
		if ( strResult == null || strResult.length() == 0 )
			return null;
		
		Hashtable<String, Object> result = new Hashtable<String, Object>();
		
		
		try {
			JSONObject total = new JSONObject(strResult);
			String message = total.optString("message");
			if (!message.equalsIgnoreCase("OK")) {
				return null;
			}
			
			JSONArray friends = total.optJSONArray("friends");
			JSONArray pins = total.optJSONArray("pins");

			
			if ( friends != null ) {
				ArrayList<UserInfo> arrUsers = new ArrayList<UserInfo>();
				
				for (int i = 0 ; i < friends.length() ; i ++) {
					JSONObject obj = friends.getJSONObject(i);
					
					if (obj != null) {
						UserInfo data = new UserInfo();
						
						data.str_id 		= getParsingString(obj.optString("id"));
						data.str_firstname	= getParsingString(obj.optString("first_name"));
						data.str_lastname	= getParsingString(obj.optString("last_name"));
						data.str_public_code= getParsingString(obj.optString("public_code"));
						
						arrUsers.add(data);
					}
				}
				
				result.put("friends", arrUsers);
				
			}
			
			/////// pins 
			if ( pins != null ) {
				ArrayList<PinInfo> arrPins = new ArrayList<PinInfo>();
				
				for (int i = 0 ; i < pins.length() ; i ++) {
					JSONObject obj = pins.getJSONObject(i);
					
					if (obj != null) {
						PinInfo data = new PinInfo();
						
						data.str_id 	= obj.optString("id");
						data.str_url 	= obj.optString("url");
						data.str_user_id 	= obj.optString("user_id");
						data.str_category_id = obj.optString("category_id");
						data.str_title 	= obj.optString("title");
						data.str_slug 	= obj.optString("slug");
						data.str_image 	= obj.optString("image");
						data.str_description = obj.optString("description");
						
						data.str_country = obj.optString("country");
						data.str_state 	= obj.optString("state");
						data.str_city 	= obj.optString("city");
						data.str_address= obj.optString("address");
						data.str_phone = obj.optString("phone");
						data.str_lat = obj.optString("lat");
						data.str_lng = obj.optString("lng");
						
						// full address
						data.str_full_address = data.str_address + " " + data.str_city + " " + data.str_country;
		                    
						arrPins.add(data);
					}
				}
				
				result.put("pins", arrPins);
				
			}
			
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		
		return result;
		
	}
	
	
	
	
	
	////////////////////////////////////////
	public static String getParsingString(String strOld) {
		String strResult = strOld;
		if ( strResult.contains("\\n") )
			strResult = strResult.replaceAll("\\\\n", "");
		if ( strResult.contains("\\r") )
			strResult = strResult.replaceAll("\\\\r", "");
		if ( strResult.contains("\\t") )
			strResult = strResult.replaceAll("\\\\t", "");
		strResult = getUnicodeString(strResult);
		
		if ( strResult.contains("\\u") )
			strResult = strResult.replaceAll("\\\\u", "");
		if ( strResult.contains("\\") )
			strResult = strResult.replaceAll("\\\\", "");
		
		return strResult;
	}
	
	public static String getUnicodeString(String strSource) {
		String strResult = "";
		while (strSource.contains("\\u")) {
			int nIndex = strSource.indexOf("\\u");
			String strTemp = strSource.substring(nIndex + 2, nIndex + 6);
			String strReplace = "";
			try {
				int nchar = Integer.parseInt(strTemp, 16);
				int []nArray = new int[1];
				nArray[0] = nchar;
				strReplace = new String(nArray, 0, 1);
			}
			catch( Exception e) {
				e.printStackTrace();
			}
			
			strSource = strSource.replaceAll("\\\\u" + strTemp, strReplace);
		}
		
		strResult = strSource;
		return strResult;
	}
	
}
