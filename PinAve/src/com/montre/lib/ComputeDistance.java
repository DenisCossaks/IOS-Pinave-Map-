package com.montre.lib;


public class ComputeDistance {
	
	//private final static double EARTH_RADIUS = 6371.0;
	
	private static double rad(double d)
	{
	   return d * Math.PI / 180.0;
	} 
	public static double GetDistance(double lat1, double lng1, double lat2, double lng2)
	{
		double radiusEarth = 6371.0 / 1.609344; // in miles
		
		double dlat = rad(lat1 - lat2);
		double dlon = rad(lng1 - lng2);
		
		double a = Math.sin(dlat/2.0) * Math.sin(dlat/2.0) + Math.cos(rad(lat1)) * Math.cos(rad(lat2)) * Math.sin(dlon/2.0) * Math.sin(dlon/2.0);
		double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1.0 - a));
		double s = radiusEarth * c;
		s = (double)((int)(s * 10)) / 10;//Math.round(s * 1000) / 1000;
		return s;

	   /*double radLat1 = rad(lat1);
	   double radLat2 = rad(lat2);
	   double a = radLat1 - radLat2;
	   double b = rad(lng1) - rad(lng2);
	   double s = 2 * Math.asin(Math.sqrt(Math.pow(Math.sin(a/2),2) + 
	    Math.cos(radLat1)*Math.cos(radLat2)*Math.pow(Math.sin(b/2),2)));
	   s = s * EARTH_RADIUS;
	   s = Math.round(s * 10000) / 10000;
	   return s;*/
	}

}
