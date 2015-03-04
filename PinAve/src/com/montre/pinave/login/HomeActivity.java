package com.montre.pinave.login;

import com.montre.pinave.R;
import com.montre.pinave.R.id;
import com.montre.pinave.R.layout;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;


public class HomeActivity extends Activity {
    /** Called when the activity is first created. */
	

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags( WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
						| WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
						| WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
		
		setContentView(R.layout.home);
        
        initView();
        
    }
    
    public void initView() {
    	
    	Button btnFb = (Button) findViewById(R.id.btn_home_fb);
    	btnFb.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				
			}
		});
    	
    	Button btnRegister = (Button) findViewById(R.id.btn_home_register);
    	btnRegister.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(HomeActivity.this, SignupActivity.class);
				startActivity(intent);
				finish();
			}
		});
    	
    	Button btnLogin = (Button) findViewById(R.id.btn_home_login);
    	btnLogin.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(HomeActivity.this, LoginActivity.class);
				startActivity(intent);
				finish();
			}
		});
    	
    	
    	TextView tvTerms = (TextView) findViewById(R.id.tv_home_terms);
    	tvTerms.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(HomeActivity.this, TermsActivity.class);
				startActivity(intent);
			}
		});
    	
    	TextView tvPolicy = (TextView) findViewById(R.id.tv_home_policy);
    	tvPolicy.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(HomeActivity.this, PolicyActivity.class);
				startActivity(intent);
				
			}
		});
    	
    }

}