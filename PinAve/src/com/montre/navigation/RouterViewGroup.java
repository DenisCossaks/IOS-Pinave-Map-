package com.montre.navigation;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import com.montre.ui.router.RouterActivity;

public class RouterViewGroup extends NavigationGroupActivity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		super.onCreate(savedInstanceState);
		
		Intent intent = new Intent(this, RouterActivity.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
				| Intent.FLAG_ACTIVITY_SINGLE_TOP);
		View view = getLocalActivityManager().startActivity(
				"Recent", intent).getDecorView();
		replaceView(view, "Recent");
	}

	@Override
	public void onBackPressed() { 
		super.onBackPressed();
	}
}
