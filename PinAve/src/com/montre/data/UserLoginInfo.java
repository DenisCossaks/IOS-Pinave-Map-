package com.montre.data;

import com.montre.lib.UserDefault;

public class UserLoginInfo {

	final static String LOGIN_NAME		= "LOGIN_NAME";
	final static String LOGIN_PASSWORD	= "LOGIN_PASSWORD";
	final static String LOGIN_CODE		= "LOGIN_CODE";
	final static String LOGIN_ID		= "LOGIN_ID";
	
	public static void setUserName(String _name) {
		UserDefault.setStringForKey(_name, LOGIN_NAME);
	}
	public static String getUserName() {
		return UserDefault.getStringForKey(LOGIN_NAME, "");
	}
	
	public static void setPassword(String _password) {
		UserDefault.setStringForKey(_password, LOGIN_PASSWORD);
	}
	public static String getPassword() {
		return UserDefault.getStringForKey(LOGIN_PASSWORD, "");
	}
	
	public static void setLoginCode(String _code) {
		UserDefault.setStringForKey(_code, LOGIN_CODE);
	}
	public static String getLoginCode() {
		return UserDefault.getStringForKey(LOGIN_CODE, "");
	}
	
	public static void setLoginId(String _id) {
		UserDefault.setStringForKey(_id, LOGIN_ID);
	}
	public static String getLoginId() {
		return UserDefault.getStringForKey(LOGIN_ID, "");
	}
	
	public static boolean isLogin () {
		
		if (getUserName().equals("") || getPassword().equals("")) {
			return false;
		}
		
		return true;
	}
}
