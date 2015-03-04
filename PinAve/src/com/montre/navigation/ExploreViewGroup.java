package com.montre.navigation;


import com.montre.ui.explore.ExploreActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

public class ExploreViewGroup extends NavigationGroupActivity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		Intent intent = new Intent(this, ExploreActivity.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
				| Intent.FLAG_ACTIVITY_SINGLE_TOP);
		View view = getLocalActivityManager().startActivity(
				"ExploreActivity", intent).getDecorView();
		replaceView(view, "ExploreActivity");
	}

	@Override
	public void onBackPressed() { 
		super.onBackPressed();
	}
}