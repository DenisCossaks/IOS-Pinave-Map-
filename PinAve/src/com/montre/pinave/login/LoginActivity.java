package com.montre.pinave.login;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Vector;

import org.apache.http.NameValuePair;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;

import com.montre.data.UserLoginInfo;
import com.montre.lib.Const;
import com.montre.lib.UserDefault;
import com.montre.pinave.BottomTab;
import com.montre.pinave.R;
import com.montre.pinave.R.id;
import com.montre.pinave.R.layout;
import com.montre.util.JsonParser;

public class LoginActivity extends Activity {
    /** Called when the activity is first created. */
	
	EditText m_editUsername;
	EditText m_editPassword;
	
	ProgressDialog progress = null;
	
	
	final int LOGIN_OK				 = 0;
	final int LOGIN_FAIL			 = 1;
	

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags( WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
						| WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
						| WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);

        setContentView(R.layout.login);
        
        initView();
    }
    
    public void initView() {
    	m_editUsername = (EditText) findViewById(R.id.edit_login_username);
    	m_editPassword = (EditText) findViewById(R.id.edit_login_password);
    	
    	
    	m_editUsername.setText(UserDefault.getStringForKey("save_username", ""));
    	m_editPassword.setText(UserDefault.getStringForKey("save_password", ""));
    	

    	Button btnJoin = (Button) findViewById(R.id.btn_login_join);
    	btnJoin.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onLogin();
			}
		});
    	
    	Button btnCancel = (Button) findViewById(R.id.btn_left);
    	btnCancel.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onBackPressed();
			}
		});
    	
    	
    	TextView tvTerms = (TextView) findViewById(R.id.tv_home_terms);
    	tvTerms.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(LoginActivity.this, TermsActivity.class);
				startActivity(intent);
				
			}
		});
    	
    	TextView tvPolicy = (TextView) findViewById(R.id.tv_home_policy);
    	tvPolicy.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(LoginActivity.this, PolicyActivity.class);
				startActivity(intent);
			}
		});
    	
    	progress = new ProgressDialog(this);
    	progress.setMessage("Loading....");
    }
    
	
	public void onLogin() {
		if (m_editUsername.getText().toString().length() < 1) {
			Const.showMessage("Username Error", "Your must input username", this);
			return;
		}
		if (m_editPassword.getText().toString().length() < 1) {
			Const.showMessage("Password Error", "Your must input password", this);
			return;
		}
	  
		progress.show();
		
		new Thread(){
			public void run(){
				loginProcess();
			}
		}.start();
	    
	}
	
	 public void loginProcess() {
	    	String username = m_editUsername.getText().toString();
	    	String password = m_editPassword.getText().toString();

			ArrayList<String> data = JsonParser.getUserLogin(username, password);
			
			if (data == null || data.size() < 2 ||
					data.get(0) == null || data.get(1) == null ||
					!data.get(0).equalsIgnoreCase("ok") || data.get(1).length() == 0 ) {
				
				m_handler.sendEmptyMessage(LOGIN_FAIL);
				return;
			}

			System.out.println(data.get(0) + "," + data.get(1));

			UserLoginInfo.setUserName(username);
			UserLoginInfo.setPassword(password);
			UserLoginInfo.setLoginCode(data.get(1));
			UserLoginInfo.setLoginId(data.get(2));
			
			m_handler.sendEmptyMessage(LOGIN_OK);
		}
	

	
	 public Handler m_handler = new Handler() {
			
			public void handleMessage(Message msg) {
				super.handleMessage(msg);
				
				progress.hide();
				
				switch (msg.what) {
				case LOGIN_OK:
					gotoExplorer();
					
					break;
					
				case LOGIN_FAIL:
					
					Const.showMessage("", "Login failed.", LoginActivity.this);

					break;
				}
				
			}
	 };
	    
	
	 public void gotoExplorer() {
		 Const.Debug("login ok");
		 
 	     UserDefault.setStringForKey(m_editUsername.getText().toString(), "save_username");
 	     UserDefault.setStringForKey(m_editPassword.getText().toString(), "save_password");
	    	
		 Intent intent = new Intent(LoginActivity.this, BottomTab.class);
		 intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
		 startActivity(intent);
		 finish();
	 }
	 
	 @Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
//		super.onBackPressed();

		 Intent intent = new Intent(LoginActivity.this, HomeActivity.class);
		 intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
		 startActivity(intent);
		 finish();
		 
	}
}