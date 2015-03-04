package com.montre.navigation;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

public class NavigationActivity extends Activity {
	
	/*@Override
	public View onCreateView(String name, Context context, AttributeSet attrs) {
		strID = name;
		return super.onCreateView(name, context, attrs);
	}*/

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags( WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
						| WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
						| WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);

//		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
//				WindowManager.LayoutParams.FLAG_FULLSCREEN);
	}
	
	public void goNextHistory(String id, Intent intent) { 
		NavigationGroupActivity parent = ((NavigationGroupActivity) getParent());
		//Oh no! I am very sorry.
		String strInsertID = id;
		int i = 0;
		if ( parent.strAllID.contains(strInsertID) )
		{
			for ( i = 0; i < 50000; ++i ) {
				if ( !parent.strAllID.contains(strInsertID + i))
					break;
			}
			strInsertID = strInsertID + i;
		}
		
		
		View view = parent.group.getLocalActivityManager().startActivity(strInsertID,
				intent).getDecorView();
		parent.group.replaceView(view, strInsertID);
	}

	@Override
	public void onBackPressed() {
		NavigationGroupActivity parent = ((NavigationGroupActivity) getParent());
		parent.back();
	}
}
