package com.montre.ui.basic;

import android.app.AlertDialog;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.view.Window;

import com.montre.navigation.NavigationActivity;
import com.montre.pinave.BottomTab;

public abstract class BasicUI extends NavigationActivity {
	
	
	public static int favourityCount = 0;
	
	 
	
	public boolean checkInternetConnection()
	{
		ConnectivityManager manager = (ConnectivityManager) getSystemService(CONNECTIVITY_SERVICE);
		NetworkInfo info = manager.getActiveNetworkInfo();  
		if(info!=null && info.isAvailable())
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
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
	public void showMessage(String msg)
	{
		AlertDialog.Builder dialog = new AlertDialog.Builder(getParent());
		//dialog.setTitle("");
		//dialog.
		dialog.setMessage(msg);
		dialog.setIcon(android.R.drawable.ic_dialog_info);
		dialog.setNegativeButton("Ok", null);
		dialog.show();
	}
	
	
	public void reFreshFavourtyButton(int number)
	{
		//favour.refresh(number);
		BottomTab.tabActivity.refreshTab(number);
	}
	
	//set full screen
	public void setFullScreen()
	{
		requestWindowFeature(Window.FEATURE_NO_TITLE);
        //getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
	}
	
	
	//Disable back 
	@Override
	public void onBackPressed() {
		super.onBackPressed();
	}
	
	
	public abstract void initViews();
	public abstract void initData();
	
}
