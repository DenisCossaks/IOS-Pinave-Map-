package com.montre.pinave;

import android.app.TabActivity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.TabHost;
import android.widget.TabWidget;
import android.widget.TabHost.TabSpec;
import android.widget.TextView;
import android.widget.TabHost.OnTabChangeListener;

import com.montre.data.Notification;
import com.montre.etc.NotifyThread;
import com.montre.lib.UserDefault;
import com.montre.navigation.ExploreViewGroup;
import com.montre.navigation.MyAvenueViewGroup;
import com.montre.navigation.PlacePinViewGroup;
import com.montre.navigation.RouterViewGroup;
import com.montre.navigation.SettingViewGroup;
import com.montre.ui.basic.BasicUI;
import com.montre.ui.explore.ExploreActivity;
import com.montre.ui.router.RouterActivity;

public class BottomTab extends TabActivity implements OnTabChangeListener {
	TabHost tabHost;

	String strCurrentTabID = "tab_1";

	public static BottomTab tabActivity;

	public static NotifyThread _notiThread;
	public static NotifyThread _notiEnablel;
	
	
	@SuppressWarnings("unused")
	public void refreshTab(int nNum) {

//		if (strCurrentTabID == "tab_1") {
//			tabHost.getTabWidget().setBackgroundResource(R.drawable.tab_1_r);
//		} else if (strCurrentTabID == "tab_2") {
//			tabHost.getTabWidget().setBackgroundResource(R.drawable.tab_2_r);
//		} else if (strCurrentTabID == "tab_3") {
//			tabHost.getTabWidget().setBackgroundResource(R.drawable.tab_3_r);
//		} else if (strCurrentTabID == "tab_4") {
//			tabHost.getTabWidget().setBackgroundResource(R.drawable.tab_4_r);
//		} else if (strCurrentTabID == "tab_5") {
//			tabHost.getTabWidget().setBackgroundResource(R.drawable.tab_5_r);
//		}

	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags(
				WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
						| WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
						| WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);

		setContentView(R.layout.sub);

		tabActivity = this;

		
		Resources ressources = getResources();
		TabHost tabHost = getTabHost();

		// Explore tab
		Intent intentExplore = new Intent().setClass(this,
				ExploreViewGroup.class);
		TabSpec tabSpecExplore = tabHost
				.newTabSpec("Explore")
				.setIndicator("",
						ressources.getDrawable(R.drawable.tab_icon_explore))
				.setContent(intentExplore);

		// MyAvenue tab
		Intent intentMyAvenue = new Intent().setClass(this,
				MyAvenueViewGroup.class);
		TabSpec tabSpecMyAvenue = tabHost
				.newTabSpec("MyAvenue")
				.setIndicator("",
						ressources.getDrawable(R.drawable.tab_icon_myavenue))
				.setContent(intentMyAvenue);

		// Placepin tab
		Intent intentPlacePin = new Intent().setClass(this,
				PlacePinViewGroup.class);
		TabSpec tabSpecPlacePin = tabHost
				.newTabSpec("PlacePin")
				.setIndicator("",
						ressources.getDrawable(R.drawable.tab_icon_placepin))
				.setContent(intentPlacePin);

		// Router tab
		Intent intentRouter = new Intent().setClass(this, RouterViewGroup.class);
		TabSpec tabSpecRouter = tabHost
				.newTabSpec("Router")
				.setIndicator(
						"",
						ressources
								.getDrawable(R.drawable.tab_icon_router))
				.setContent(intentRouter);

		// Setting tab
		Intent intentSetting = new Intent().setClass(this,
				SettingViewGroup.class);
		TabSpec tabSpecSetting = tabHost
				.newTabSpec("Setting")
				.setIndicator(
						"",
						ressources
								.getDrawable(R.drawable.tab_icon_setting))
				.setContent(intentSetting);

		// add all tabs
		tabHost.addTab(tabSpecExplore);
		tabHost.addTab(tabSpecMyAvenue);
		tabHost.addTab(tabSpecPlacePin);
		tabHost.addTab(tabSpecRouter);
		tabHost.addTab(tabSpecSetting);

		// set Windows tab as default (zero based)
		tabHost.setCurrentTab(0);

/*		
		if (Notification.getNotify() == false) {
			setNotifyStart(true);
		} else {
			setNotification();
		}
*/
		
	}

	@Override
	public void onTabChanged(String tabId) {
		strCurrentTabID = tabId;
		 if(tabId == "tab_1")
		 {
		 tabHost.getTabWidget().setBackgroundResource(R.drawable.tab_1_r);
		 }else if(tabId == "tab_2"){
		 tabHost.getTabWidget().setBackgroundResource(R.drawable.tab_2_r);
		 }else if(tabId == "tab_3"){
		 tabHost.getTabWidget().setBackgroundResource(R.drawable.tab_3_r);
		 }else if(tabId == "tab_4"){
		 tabHost.getTabWidget().setBackgroundResource(R.drawable.tab_4_r);
		 }else if(tabId == "tab_5"){
		 tabHost.getTabWidget().setBackgroundResource(R.drawable.tab_5_r);
		 }

		// refreshTab(BasicUI.favourityCount);
	}

	
	public static void setNotification() {
		
		_notiThread = new NotifyThread(tabActivity, 0);
		if (Notification.getNotify()) {
			_notiThread.start(Notification.getMinute());
		} else {
			_notiThread.stop();
		}
	}
	
	public static void setNotifyStart(boolean start) {
		_notiEnablel = new NotifyThread(tabActivity, 1);
		if (start) {
			_notiEnablel.start(Notification.getDuration());
		} else {
			_notiEnablel.stop();
		}
	}
	
	
	private class MyTabView extends LinearLayout {
		// public MyTabView(Context c, int drawable, String label) {
		public MyTabView(Context c, String label) {
			super(c);
			// ImageView iv = new ImageView(c);
			// iv.setImageResource(drawable);

			TextView tv = new TextView(c);
			tv.setText(label);
			tv.setGravity(0x01);

			setOrientation(LinearLayout.VERTICAL);
			// addView(iv);
			addView(tv);
		}
	}

}
