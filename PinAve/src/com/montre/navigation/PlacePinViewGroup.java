package com.montre.navigation;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import com.montre.ui.placepin.PlacePinActivity;

public class PlacePinViewGroup extends NavigationGroupActivity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);

		Intent intent = new Intent(this, PlacePinActivity.class);

		intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
				| Intent.FLAG_ACTIVITY_SINGLE_TOP);
		View view = getLocalActivityManager().startActivity("OurOffices",
				intent).getDecorView();
		replaceView(view, "OurOffices");

	}

	@Override
	public void onBackPressed() {
		super.onBackPressed();
	}
}
