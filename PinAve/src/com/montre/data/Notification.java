package com.montre.data;

import java.util.ArrayList;
import java.util.TimeZone;

import com.montre.lib.Const;
import com.montre.lib.UserDefault;

public class Notification {
	
	final static String NOTI_SET		= "NOTI_SET";
	final static String NOTI_DISTANCE	= "NOTI_DISTANCE";
	final static String NOTI_MINUTE		= "NOTI_MINUTE";
	final static String NOTI_DURATION	= "NOTI_DURATION";
	final static String NOTI_CATEGORY	= "NOTI_CATEGORY";
	
	
	//////////// Setting
	public static int 	UNIT_KM 	= 0;
	public static int 	UNIT_MILE	= 1;
	
	public static int 	RADIUS_1	= 1;
	public static int 	RADIUS_2	= 2;
	public static int 	RADIUS_5	= 5;
	public static int 	RADIUS_10	= 10;
	

	public static int 	MINUTE_1	= 1;
	public static int 	MINUTE_3	= 3;
	public static int 	MINUTE_5	= 5;
	public static int 	MINUTE_10	= 10;
	public static int 	MINUTE_15	= 15;
	public static int 	MINUTE_30	= 30;
	public static int 	MINUTE_60	= 60;
	
	
	
	public static void setNotify(boolean bSet) {
		UserDefault.setBoolForKey(bSet, NOTI_SET);
		
	}
	public static boolean getNotify(){
		return UserDefault.getBoolForKey(NOTI_SET, false);
	}
	
	
	public static void setDistance(int distance) {
		UserDefault.setIntForKey(distance, NOTI_DISTANCE);
	}
	
	public static int getDistance(){
		return UserDefault.getIntForKey(NOTI_DISTANCE, RADIUS_2);
	}
	
	
	public static void setMinute(int minute) {
		UserDefault.setIntForKey(minute, NOTI_MINUTE);
	}
	public static int getMinute() {
		return UserDefault.getIntForKey(NOTI_MINUTE, MINUTE_15);
	}
	
	
	public static void setDuration(int duration) {
		UserDefault.setIntForKey(duration, NOTI_DURATION);
	}
	public static int getDuration(){
		return UserDefault.getIntForKey(NOTI_DURATION, 2);
	}
	
	public static void setCategory(ArrayList<CategoryInfo> lists){
		
		for (int i = 0; i < Share.g_arrCategory.size(); i++) {
			CategoryInfo category = Share.g_arrCategory.get(i);
			
			UserDefault.setBoolForKey(isSelected(category.strId, lists), NOTI_CATEGORY + category.strId);
		}		
		
	}
	
	public static ArrayList<CategoryInfo> getCategory() {
		
		ArrayList<CategoryInfo> lists = new ArrayList<CategoryInfo>();
		
		for (int i = 0; i < Share.g_arrCategory.size(); i++) {
			CategoryInfo category = Share.g_arrCategory.get(i);
		
			boolean bResult = UserDefault.getBoolForKey(NOTI_CATEGORY + category.getId(), true);
			
			category.setSelect(bResult);
			
			lists.add(category);
		}
		
		return lists;
	}
	
	private static boolean isSelected(String key, ArrayList<CategoryInfo> arry) {
		if (arry == null)
			return false;
		
		for (int i = 0; i < arry.size(); i++) {
			CategoryInfo info = arry.get(i);
			
			if (info.strId.equals(key)) {
				return info.getSelect();
			}
		}
		
		return false;
	}
	
	public static boolean isEnableCategory() {
		
		ArrayList<CategoryInfo> list = getCategory();
		for (int i = 0; i < list.size(); i++) {
			if (list.get(i).getSelect() == true) {
				return true;
			}
		}
		
		return false;
	}

}