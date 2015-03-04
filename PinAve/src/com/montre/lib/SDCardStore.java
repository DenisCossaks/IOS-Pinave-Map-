package com.montre.lib;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Hashtable;
import java.util.Vector;

import com.montre.pinave.MainActivity;


import android.app.Activity;
import android.content.SharedPreferences;


public class SDCardStore {
	
	
	public static void setIntForKey(int value, String forkey) {
		
		setStringForKey("" + value, forkey);
	}

	public static int getIntForKey(String forkey, int defaultVal){
		
		String result = getStringForKey(forkey, "" + defaultVal);

		int iResult;
		try {
			iResult = Integer.parseInt(result);
		} catch (Exception e) {
			// TODO: handle exception
			iResult = defaultVal;
		}
		return iResult;
		
	}
	
	public static void setFloatForKey(float value, String forkey) {
		
		setStringForKey("" + value, forkey);
	}

	public static float getFloatForKey(String forkey, float defValue){
		
		String result = getStringForKey(forkey, "" + defValue);

		float fResult;
		try {
			fResult = Float.parseFloat(result);
		} catch (Exception e) {
			// TODO: handle exception
			fResult = defValue;
		}
		return fResult;
		
	}

	public static void setBoolForKey(boolean value, String forkey) {
		
		setStringForKey("" + value, forkey);
	}

	public static boolean getBoolForKey(String forkey, boolean defValue){
		
		String result = getStringForKey(forkey, "" + defValue);
		
		if (result.equalsIgnoreCase("false")){
			return false;
		}
		else {
			return true;
		}
		
	}

	
		
	public static void setStringForKey(String value, String forkey) {
		
		try {
			String filePath = Const.FILE_PATH + forkey + ".txt";
			File temp = new File(filePath);
			if(!temp.exists()){
				File folder = new File(Const.FILE_PATH);
				folder.mkdir();
				temp = null;
			}
			
			File file = new File(filePath);
			file.createNewFile();
			
			FileOutputStream out = new FileOutputStream(file);
			
			String totalBuffer= value;
			byte strBuffer[] = totalBuffer.getBytes();
			
			out.write(strBuffer);
			out.close();
		}catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
		
	}

	public static String getStringForKey(String forkey, String defValue){
		
		String filePath = Const.FILE_PATH + forkey + ".txt";
		
		String szTotalScript;
		File file = new File(filePath);
		if(!file.exists()){
			System.out.println("No file exist");
			return defValue;
		}
		
		try {
		FileInputStream str = new FileInputStream(file);
		
		
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			byte tempByte[] = new byte[(int) file.length()];
			do {
					int numread = str.read(tempByte);
					if (numread <= 0)
						break;
					baos.write(tempByte, 0, numread);
				} while (true);
			
			szTotalScript = baos.toString();
			
			str.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return defValue;
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			return defValue;
		}
		
		return szTotalScript;
	}
	
	
	
}
