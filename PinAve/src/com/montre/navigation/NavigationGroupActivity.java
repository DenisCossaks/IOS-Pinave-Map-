package com.montre.navigation;

import java.util.ArrayList;

import android.app.ActivityGroup;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

public class NavigationGroupActivity extends ActivityGroup {
	
	@Override
	protected void onDestroy() {
		history.clear();
		strID.clear();
		strAllID.clear();
		super.onDestroy();
	}

	ArrayList<View> history;
	ArrayList<String> strID;
	ArrayList<String> strAllID;
	NavigationGroupActivity group;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		super.onCreate(savedInstanceState);
		
		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags( WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
						| WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
						| WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);

		
		history = new ArrayList<View>();
		strID = new ArrayList<String>();
		strAllID = new ArrayList<String>();
		group = this;
	}

	public void changeView(View v, String id) {
		
		strID.remove(history.size() - 1);
		history.remove(history.size() - 1);
		history.add(v);
		strID.add(id);
		setContentView(v);
	}

	public void replaceView(View v, String id) {
		
		Log.d("MK", "REPLACE VIEW...");
		strID.add(id);
		strAllID.add(id);
		history.add(v);
		setContentView(v);
	}

	public void back() {
		if (history.size() > 1) {
			group.getLocalActivityManager().destroyActivity(strID.get(strID.size() - 1), true);
			history.remove(history.size() - 1);
			strID.remove(strID.size() - 1);
			setContentView(history.get(history.size() - 1));
		} else {
			finish();
		}
	}

	@Override
	public void onBackPressed() {
		group.back();
		return;
	}
}