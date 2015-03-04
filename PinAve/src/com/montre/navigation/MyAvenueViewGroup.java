package com.montre.navigation;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;


import com.montre.ui.myavenue.MyAvenueActivity;

public class MyAvenueViewGroup extends NavigationGroupActivity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		
		Intent intent = new Intent(this, MyAvenueActivity.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
				| Intent.FLAG_ACTIVITY_SINGLE_TOP);
		
		View view = getLocalActivityManager().startActivity(
				"Favourite", intent).getDecorView();
		replaceView(view, "Favourite");
	}

	@Override
	public void onBackPressed() { 
		super.onBackPressed();
	}
}
