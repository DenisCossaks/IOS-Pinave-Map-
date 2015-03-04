package com.montre.data;

import java.io.Serializable;
import java.util.ArrayList;

public class CustomLocation implements Serializable{
	
	private static final long serialVersionUID = 1L;

	private double lat = 0.0f;
	private double lng = 0.0f;
	
	private String title = "";
	
	
	public CustomLocation() {
		// TODO Auto-generated constructor stub
		lat = 0.0f;
		lng = 0.0f;
	}
	
	public CustomLocation (double lat, double lng) {
		this.lat = lat;
		this.lng = lng;
	}
		
	public double getLatitude () {
		return this.lat;
	}
	public void setLatitude(double lat) {
		this.lat = lat;
	}
	
	public double getLongitude () {
		return this.lng;
	}
	public void setLongitude (double lng) {
		this.lng = lng;
	}
	
	public String getTitle(){
		return this.title;
	}
	public void setTitle(String _title) {
		this.title = _title;
	}
}
