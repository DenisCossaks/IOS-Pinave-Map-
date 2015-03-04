package com.montre.ui.basic;

import android.app.AlertDialog;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;

import com.montre.navigation.NavigationMapActivity;
import com.montre.pinave.BottomTab;


public abstract class BasicMapUI extends NavigationMapActivity {

	
	/*protected ImageButton search;
	protected MyImageButton favour;
	protected ImageButton recent;
	protected ImageButton calculator;
	protected ImageButton office_;*/

	public void back() {
		onBackPressed();
	}
	
	@Override
	public void onBackPressed() {
		
		super.onBackPressed();
	}

	public Location my_location;

	
	

	
	public void reFreshFavourtyButton(int number) {
		BottomTab.tabActivity.refreshTab(number);
	}

	
	/*public void addListener() {
		BottomButtonListener listener = new BottomButtonListener();
		search.setOnClickListener(listener);
		favour.setOnClickListener(listener);
		recent.setOnClickListener(listener);
		calculator.setOnClickListener(listener);
		office_.setOnClickListener(listener);
	}*/

	public void showMessage(String title,String msg)
	{
		AlertDialog.Builder dialog = new AlertDialog.Builder(getParent());
		dialog.setTitle(title);
		//dialog.
		dialog.setMessage(msg);
		dialog.setIcon(android.R.drawable.ic_dialog_info);
		dialog.setNegativeButton("Ok", null);
		dialog.show();
	}
	public void showMessage(String msg) {
		AlertDialog.Builder dialog = new AlertDialog.Builder(getParent());
		dialog.setTitle("Error");
		dialog.setMessage(msg);
		dialog.setIcon(android.R.drawable.ic_dialog_info);
		dialog.setNegativeButton("Ok", null);
		dialog.show();
	}

	public boolean checkInternetConnection() {
		ConnectivityManager manager = (ConnectivityManager) getSystemService(CONNECTIVITY_SERVICE);
		NetworkInfo info = manager.getActiveNetworkInfo();
		if (info != null && info.isAvailable()) {
			return true;
		} else {
			return false;
		}
	}

	public Location getLocation() {
		
		final LocationManager lmg = (LocationManager) getSystemService(LOCATION_SERVICE);
		my_location = lmg.getLastKnownLocation(LocationManager.GPS_PROVIDER);
		if (my_location == null) {
			my_location = lmg
					.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
		}
		return my_location;
	}

	public abstract void initViews();

	public abstract void initData();

	public abstract void setListener();

	public abstract void initMap();

	@Override
	protected boolean isRouteDisplayed() {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	protected void onPause() {
		/*final LocationManager lmg = (LocationManager) getSystemService(LOCATION_SERVICE);
		lmg.removeUpdates(locationlistener);*/
		super.onPause();
	}

	@Override
	protected void onResume() {
		
		super.onResume();
	}

	LocationListener locationlistener = new LocationListener() {
		
		@Override
		public void onStatusChanged(String provider, int status, Bundle extras) {
			// TODO Auto-generated method stub
			
		}
		
		@Override
		public void onProviderEnabled(String provider) {
			// TODO Auto-generated method stub
			
		}
		
		@Override
		public void onProviderDisabled(String provider) {
			// TODO Auto-generated method stub
			
		}
		
		@Override
		public void onLocationChanged(Location location) {
			my_location.set(location);
			
		}
	};
}
