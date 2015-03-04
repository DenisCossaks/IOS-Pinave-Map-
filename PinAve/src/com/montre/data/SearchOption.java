package com.montre.data;

import java.util.ArrayList;
import java.util.TimeZone;

import com.montre.lib.Const;
import com.montre.lib.UserDefault;

public class SearchOption {
	
	final static String SEARCH_CATEGORY	= "SEARCH_CATEGORY";
	
	public static void setCategory(ArrayList<CategoryInfo> lists){
		
		for (int i = 0; i < Share.g_arrCategory.size(); i++) {
			CategoryInfo category = Share.g_arrCategory.get(i);
			
			String key = SEARCH_CATEGORY + category.strId;
			UserDefault.setBoolForKey(isSelected(category.strId, lists), key);
		}		
		
	}
	public static ArrayList<CategoryInfo> getCategory() {
		
		ArrayList<CategoryInfo> lists = new ArrayList<CategoryInfo>();
		
		for (int i = 0; i < Share.g_arrCategory.size(); i++) {
			CategoryInfo category = Share.g_arrCategory.get(i);
		
			String key = SEARCH_CATEGORY + category.getId();
			
			boolean bResult = UserDefault.getBoolForKey(key, true);
			
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
