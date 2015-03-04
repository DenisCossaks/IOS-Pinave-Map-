package com.montre.navigation;

import com.montre.ui.setting.SettingActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;


public class SettingViewGroup extends NavigationGroupActivity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		
		Intent intent = new Intent(this, SettingActivity.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
				| Intent.FLAG_ACTIVITY_SINGLE_TOP);
		View view = getLocalActivityManager().startActivity(
				"AdditionalInfo", intent).getDecorView();
		replaceView(view, "AdditionalInfo");
	}

	@Override
	public void onBackPressed() { 
		super.onBackPressed();
	}
}
