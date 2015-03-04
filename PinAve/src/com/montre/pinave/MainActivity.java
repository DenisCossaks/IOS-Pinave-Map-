package com.montre.pinave;

import java.io.File;
import java.util.ArrayList;
import java.util.Calendar;


import com.custom.gallery.IntroduceActivity;
import com.montre.data.UserInfo;
import com.montre.data.UserLoginInfo;
import com.montre.lib.Const;
import com.montre.lib.UserDefault;
import com.montre.pinave.login.HomeActivity;
import com.montre.util.JsonParser;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.PendingIntent;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Window;
import android.view.WindowManager;

public class MainActivity extends Activity {
    /** Called when the activity is first created. */
	
	
	final int PROGRESS_DIALOG_LOGIN  = 1;
	final int LOGIN_OK				 = 0;
	final int NETWORK_FAIL			 = 1;
	
	ProgressDialog progress = null;
	
	public static MainActivity _main = null;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags( WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
						| WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
						| WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
		
		
        setContentView(R.layout.main);
    
        _main = this;
        
//        UserDefault.init(this);
        
        if ( !checkInternetConnection() ) {
			m_handler.sendEmptyMessage(NETWORK_FAIL);
			return;
		}
        
        initData();
        
        
    }
    
    
	private static Handler handler = new Handler(); 
	
    public void initData() {
    	
    	Thread thread = new Thread(new Runnable(){

			public void run() {
				// TODO Auto-generated method stub
				try {
					Thread.sleep(3000);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
				handler.post(new Runnable() {
					public void run() {
						gotoNextScreen();
					}
				});
				
			}
			
		});
		thread.start();
    	
    	return;
	}
    
    
    private void gotoNextScreen() {
    	File file = new File(Const.FILE_PATH);
    	if (!file.exists()) 
    		file.mkdirs();
    	
    	if (UserLoginInfo.isLogin()) {
    		login();
    	} 
    	else
    	{
    		gotoLoginView();
    	}
    	
    }
    
    public void gotoLoginView() {	
    	Intent intent;
    	
    	boolean bFirst = UserDefault.getBoolForKey("first", true);
    	
    	if (bFirst) {
    		UserDefault.setBoolForKey(false, "first");
    		intent = new Intent(MainActivity.this, IntroduceActivity.class);
    		intent.putExtra("mode", 1);
    	} else {
    		intent = new Intent(MainActivity.this, HomeActivity.class);
    	}
		
		startActivity(intent);
		finish();
	}
    private void gotoExploreView(){
    	Intent intent = new Intent(MainActivity.this, BottomTab.class);
    	startActivity(intent);
		finish();
    }
    
    private void login() {
    	
//    	showDialog(PROGRESS_DIALOG_LOGIN);
    	progress = new ProgressDialog(this);
		progress.setCancelable(false);
		progress.setMessage("Loading...");
    	
		progress.show();
		
    	Mythread myThread = new Mythread();
		Thread thread = new Thread(myThread);
		thread.start();
    }
    
    public class Mythread implements Runnable {

		@Override
		public void run() {
			
			try {
				loginProcess();	
			} catch (Exception e) {
				m_handler.sendEmptyMessage(NETWORK_FAIL);
			}
	 
		}
	}
    
    public void loginProcess() {
    	String username = UserLoginInfo.getUserName();
    	String password = UserLoginInfo.getPassword();

    	ArrayList<String> data = JsonParser.getUserLogin(username, password);

		if (data == null || data.size() < 2 ||
				data.get(0) == null || data.get(1) == null ||
				!data.get(0).equalsIgnoreCase("ok") || data.get(1).length() == 0 ) {
			
//			UserLoginInfo.setUserName("");
//			UserLoginInfo.setPassword("");
//			UserLoginInfo.setLoginCode("");

			Const.showMessage("", "Login failed.", this);
			return;
		}
		
		UserLoginInfo.setUserName(username);
		UserLoginInfo.setPassword(password);
		UserLoginInfo.setLoginCode(data.get(1));
		
		m_handler.sendEmptyMessage(LOGIN_OK);
	}
    
    
//    protected Dialog onCreateDialog(int id) {
//		switch (id) {
//		case PROGRESS_DIALOG_LOGIN:
//			ProgressDialog dialog = new ProgressDialog(this);
//			dialog.setCancelable(false);
//			dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
//			dialog.setMessage("Loading...");
//			
//			new Thread(new Runnable() {
//				
//				public void run() {
//					loginProcess();
//				}
//			}).start();
//			return dialog;
//		}
//		return super.onCreateDialog(id);
//	}

    
    public Handler m_handler = new Handler() {
		
		public void handleMessage(Message msg) {
			super.handleMessage(msg);
			
			progress.hide();
			
			switch (msg.what) {
			case LOGIN_OK:
				
				gotoExploreView();
				break;
				
			case NETWORK_FAIL:
				AlertDialog.Builder dialog = new AlertDialog.Builder(MainActivity.this);
				//dialog.setTitle("");
				dialog.setMessage("No internet available.");
				dialog.setIcon(android.R.drawable.ic_dialog_info);
				dialog.setNegativeButton("Ok", new DialogInterface.OnClickListener() {
					
					public void onClick(DialogInterface dialog, int which) {
						finish();
					}
				});
				dialog.show();
				break;
			}
			
		}
    	
    };
    
    
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
}