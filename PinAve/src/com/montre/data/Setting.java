package com.montre.data;

import java.util.TimeZone;

import com.montre.lib.UserDefault;

public class Setting {
	
	final static String SETTING_UNIT	= "SETTING_UNIT";
	final static String SETTING_RADIUS	= "SETTING_RADIUS";
	final static String SETTING_PINS	= "SETTING_PINS";
	final static String SETTING_TIMEZONE	= "SETTING_TIMEZONE";
	final static String SETTING_MAPMODE	= "SETTING_MAPMODE";
	
	
	//////////// Setting
	public static int 	UNIT_KM 	= 0;
	public static int 	UNIT_MILE	= 1;
	
	public static int 	RADIUS_1	= 1;
	public static int 	RADIUS_2	= 2;
	public static int 	RADIUS_5	= 5;
	public static int 	RADIUS_10	= 10;
	public static int 	RADIUS_50	= 50;
	public static int 	RADIUS_100	= 100;
	public static int 	RADIUS_200	= 200;
	public static int 	RADIUS_500	= 500;
	
	public static int 	PIN_25		= 25;
	public static int 	PIN_50		= 50;
	public static int 	PIN_100		= 100;
	public static int 	PIN_150		= 150;
	public static int 	PIN_200		= 200;
	
	public static int 	MAP_STANDARD	= 0;
	public static int 	MAP_SATELLITE	= 1;
	
	
	
	public static void setUnit(int unit) {
		UserDefault.setIntForKey(unit, SETTING_UNIT);
	}
	public static int getUnit(){
		return UserDefault.getIntForKey(SETTING_UNIT, UNIT_KM);
	}
	
	
	public static void setRadius(int radius) {
		UserDefault.setIntForKey(radius, SETTING_RADIUS);
	}
	
	public static int getRadius(){
		return UserDefault.getIntForKey(SETTING_RADIUS, RADIUS_500);
	}
	
	
	public static void setNumberofPins(int pins) {
		UserDefault.setIntForKey(pins, SETTING_PINS);
	}
	public static int getNumberofPins() {
		return UserDefault.getIntForKey(SETTING_PINS, PIN_200);
	}

	
	public static void setMapMode(int mode) {
		UserDefault.setIntForKey(mode, SETTING_MAPMODE);
	}
	public static int getMapMode(){
		return UserDefault.getIntForKey(SETTING_MAPMODE, MAP_STANDARD);
	}
	
	public static void setTimezone(String timezone){
		UserDefault.setStringForKey(timezone, SETTING_TIMEZONE);
	}
	public static String getTimezone() {
		String timezone = UserDefault.getStringForKey(SETTING_TIMEZONE, "");
		
		if (timezone.equals("")) {
			TimeZone tz = TimeZone.getDefault();
			timezone = tz.getID();
		}
		
		return timezone;
	}
}
