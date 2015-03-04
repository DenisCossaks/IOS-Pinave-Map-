package com.montre.data;

import com.montre.pinave.R;


public class CategoryInfo {

	final public static String All_Category = "All Category";
	final public static String My_Pins		= "My Pins";
	
	
	public String strId = "";
	public String strName = "";
	public String strSlug = "";
	public String strDescription = "";
	public String strDaily = "";
	public String strIcon = "";
	
	
	public int 	pinNumber = 0;
	public boolean bSelect = false;
	
	
	public String getId() { return strId;}
	public String getName() { return strName;}
	public String getSlug() { return strSlug; }
	public String getDescription() {return strDescription; }
	public String getDaily() { return strDaily; }
	public String getIconUrl() { return strIcon; }
 	
	public int 	  getPinCount() { return pinNumber;}
	
	public void 	setSelect(boolean _sel) { bSelect = _sel;} 
	public boolean getSelect() { return bSelect; };
	
	
	
	public int getResouceId(){
		int [] idArray = {
		        R.drawable.c_allcategories,
		        R.drawable.c_accom,
		        R.drawable.c_car,
		        R.drawable.c_party,
		        R.drawable.c_food,
		        R.drawable.c_garage,
		        R.drawable.c_beauty,
		        R.drawable.c_homely,
		        R.drawable.c_jobs,
		        R.drawable.c_leisure,
		        R.drawable.c_parking,
		        R.drawable.c_sale,
		        R.drawable.c_wanted,
		        R.drawable.c_deals,
		        R.drawable.c_pay,
		        R.drawable.c_mypins,
		};
		
		String[] imgArray = {
				All_Category,
		        "Accommodation",
		        "Cars & Bikes",
		        "Events & Parties",
		        "Food & Drinks",
		        "Garage Sales",
		        "Health & Beauty",
		        "Homely Made",
		        "Jobs",
		        "Leisure",
		        "Parking",
		        "On Sale!",
		        "Wanted",
		        "Daily Deals",
		        "I'll Pay for",
		        My_Pins,
		};
		
		for (int i = 0; i < imgArray.length; i++) {
			if(imgArray[i].equalsIgnoreCase(strName)){
				return idArray[i];
			}
		}
		
		return 0;
	}
}


