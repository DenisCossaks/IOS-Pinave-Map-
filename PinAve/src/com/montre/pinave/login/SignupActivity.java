package com.montre.pinave.login;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Vector;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONObject;

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
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;

import com.montre.data.UserLoginInfo;
import com.montre.data.Utils;
import com.montre.lib.Const;
import com.montre.pinave.BottomTab;
import com.montre.pinave.R;
import com.montre.pinave.R.id;
import com.montre.pinave.R.layout;
import com.montre.util.JsonParser;

public class SignupActivity extends Activity {
    /** Called when the activity is first created. */
	
	EditText m_editFirstName;
	EditText m_editLastName;
	EditText m_editEmail;
	EditText m_editPassword;
	EditText m_editConfirmPsw;
	
	ProgressDialog progress = null;
	
	final int PROGRESS_DIALOG = 1;
	
	private String response = "";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags( WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
						| WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
						| WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);

		setContentView(R.layout.signup);
		
        initView();
       
    }
    
    public void initView() {
    	m_editFirstName = (EditText) findViewById(R.id.edit_signup_firstname);
    	m_editLastName  = (EditText) findViewById(R.id.edit_signup_lastname);
    	m_editEmail     = (EditText) findViewById(R.id.edit_signup_email);
    	m_editPassword  = (EditText) findViewById(R.id.edit_signup_password);
    	m_editConfirmPsw = (EditText) findViewById(R.id.edit_signup_confirm);

    	Button btnRegister = (Button) findViewById(R.id.btn_signup_register);
    	btnRegister.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onSignUp();
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
				Intent intent = new Intent(SignupActivity.this, TermsActivity.class);
				startActivity(intent);
				
			}
		});
    	
    	TextView tvPolicy = (TextView) findViewById(R.id.tv_home_policy);
    	tvPolicy.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(SignupActivity.this, PolicyActivity.class);
				startActivity(intent);
				
			}
		});
    	progress = new ProgressDialog(this);
    	progress.setMessage("Registering....");
    	
    }
    
	public void onSignUp() {
		if (m_editFirstName.getText().toString().length() < 1) {
			Const.showMessage("Firstname Error", "Your firstname must be at least 1 characters long.", this);
			return;
		}
		if (m_editLastName.getText().toString().length() < 1) {
			Const.showMessage("Lastname Error", "Your lastname must be at least 1 characters long.", this);
			return;
		}
		if (m_editPassword.getText().toString().length() < 6) {
			Const.showMessage("Password Error", "Your password must be at least 6 characters long.", this);
			return;
		}
		if (m_editConfirmPsw.getText().toString().length() < 1
				|| !m_editConfirmPsw.getText().toString().equals(m_editPassword.getText().toString())) {
			Const.showMessage("Password Confirm Error", "Passwords did not indentify", this);
			return;
		}
		if (m_editEmail.getText().toString().length() < 1) {
			Const.showMessage("Email Error", "You need a Email name to register.", this);
			return;
		}
	   
		progress.show();
		
		new Thread(){
			public void run(){
				signUp();
			}
		}.start();
	    
	}
	
	
	public void signUp(){
		String firstname = m_editFirstName.getText().toString();
		String lastname  = m_editLastName.getText().toString();
		String psw		 = m_editPassword.getText().toString();
		String confirmpsw= m_editConfirmPsw.getText().toString();
		String email	 = m_editEmail.getText().toString();
		
	    String firstKey = firstname;
	    String lastKey =  lastname;
	    
	    String RealKey = keyAlgorithm(firstKey, lastKey);
	    System.out.println("RealKey = " + RealKey);
	    
	    // Post data
	    
	    DefaultHttpClient hc=new DefaultHttpClient();  
	    ResponseHandler <String> res=new BasicResponseHandler();  
	    
	    System.out.println("url = " + Utils.getRegisterUrl());
	    HttpPost postMethod=new HttpPost(Utils.getRegisterUrl());
	    
	    List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();    
	    nameValuePairs.add(new BasicNameValuePair("firstname", firstname));    
	    nameValuePairs.add(new BasicNameValuePair("lastname", lastname));    
	    nameValuePairs.add(new BasicNameValuePair("password", psw));
	    nameValuePairs.add(new BasicNameValuePair("password_confirm", confirmpsw));
	    nameValuePairs.add(new BasicNameValuePair("email", email));
	    nameValuePairs.add(new BasicNameValuePair("key", RealKey));
	    
	    try{
	    	 postMethod.setEntity(new UrlEncodedFormEntity(nameValuePairs));    
			 
	    	 HttpResponse response = hc.execute(postMethod);
			 String responseBody = EntityUtils.toString(response.getEntity());
			 
			 int p1 = responseBody.indexOf("{\"message");
			 responseBody = responseBody.substring(p1);

			 System.out.println("register = " + responseBody);

			 JSONObject obj = new JSONObject(responseBody);
				
				if (obj != null) {
					String result = obj.optString("message");
					if (result.equalsIgnoreCase("ok")) {
						 
						 goLogin();
						
				  	     m_handler.sendEmptyMessage(0);
				  	     return;
					}
				}
				
	  	     m_handler.sendEmptyMessage(2);
	  	     return;
	 	
	    }catch(Exception e){
	    	e.printStackTrace();
	    	m_handler.sendEmptyMessage(1);
	   	}
	}
	
	public void goLogin()
	{
		String username	 = m_editEmail.getText().toString();
		String password	 = m_editPassword.getText().toString();
		
		ArrayList<String> data = JsonParser.getUserLogin(username, password);
		
		if (data == null || data.size() < 2 ||
				data.get(0) == null || data.get(1) == null ||
				!data.get(0).equalsIgnoreCase("ok") || data.get(1).length() == 0 ) {
			
			m_handler.sendEmptyMessage(2);
			return;
		}

		System.out.println(data.get(0) + "," + data.get(1));

		UserLoginInfo.setUserName(username);
		UserLoginInfo.setPassword(password);
		UserLoginInfo.setLoginCode(data.get(1));
		UserLoginInfo.setLoginId(data.get(2));
	}
	
	public void gotoExplorer() {
		 startActivity(new Intent(SignupActivity.this, BottomTab.class));
		 finish();
	}
	
	 @Override
		public void onBackPressed() {
			// TODO Auto-generated method stub
//			super.onBackPressed();

			 Intent intent = new Intent(SignupActivity.this, HomeActivity.class);
			 intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
			 startActivity(intent);
			 finish();
			 
		}
	 
	 public Handler m_handler = new Handler() {
			
			public void handleMessage(Message msg) {
				super.handleMessage(msg);
				
				progress.hide();
				
				switch (msg.what) {
				case 0:
					gotoExplorer();
					break;
				case 1:
					Const.showMessage("", "NO internet avaiable.", SignupActivity.this);
					break;
				case 2:
					Const.showMessage("Fail", "Register fail", SignupActivity.this);
					break;
				}
				
			}
	 };
	    
	
	private String keyAlgorithm(String firstname, String lastname)
	{
	    String sharp = "#";
	    String percent = "%";

	    String firstkey = firstname;
	    String lastkey = lastname;
	    firstkey = sharp + firstkey + percent;
	    lastkey  = sharp + lastkey + percent;
	    
	    System.out.println("sharp - " + firstkey);
	    firstkey = md5HexDigest(firstkey);
	    System.out.println("first = " + firstkey);
	    
	    lastkey =  md5HexDigest(lastkey);
	    System.out.println("last = " + lastkey);
	    
	    Vector<String> newArray = new Vector<String>();
	    
	    for(int i = 0; i<firstkey.length(); i++)
	    {
	    	String newChar = "" + firstkey.charAt(i) + lastkey.charAt(i);
	    	System.out.println("newChar = " + newChar);
//	        NSString    *newChar = [NSString stringWithFormat:@"%c%c",[firstkey characterAtIndex:i],[lastkey characterAtIndex:i]];
	
	    	newArray.addElement(newChar);
//	        [newArray addObject:newChar];
	    }
	    
//	    [newArray sortUsingSelector:@selector(sortStrings:)];
	    
	    Comparator comparator = Collections.reverseOrder();
	    Collections.sort(newArray, comparator);

	    System.out.println("sort ====================");
	    for(int i = 0; i<newArray.size(); i++){
	    	System.out.print(newArray.elementAt(i).toString() + " , ");
	    }
	    
	    
	    for(int i = 0; i<newArray.size() - 1; i++)
	    {
	        if((newArray.elementAt(i).toString()).equals(newArray.elementAt(i+1).toString()))
	        {
	        	newArray.removeElementAt(i+1);
	            
	            if(i > -1)
	                i--;
	        }
	        
	    }
	    
	    
	    
	    
//	    NSMutableString *key = [[NSMutableString alloc] init];
	    String key = "";
	    for(int i = 0; i< newArray.size(); i++)
	    {
	    	key += newArray.elementAt(i);
	    }

	    key += md5HexDigest(key);
//	    [key appendFormat:@"%@",[self md5HexDigest:key]];
	    System.out.println("KEY = " + key);
	    
	    return key;
	}
	
	private String md5HexDigest(String sessionid)
	{
//		sessionid="12345";
        
		byte[] defaultBytes = sessionid.getBytes();
		try{
			MessageDigest algorithm = MessageDigest.getInstance("MD5");
			algorithm.reset();
			algorithm.update(defaultBytes);
			byte messageDigest[] = algorithm.digest();
		            
			StringBuffer hexString = new StringBuffer();
			for (int i=0;i<messageDigest.length;i++) {
				String result = Integer.toHexString(0xFF & messageDigest[i]);
				if (result.length() < 2) {
					result = "0" + result;
				}
				hexString.append(result);
			}
			String foo = messageDigest.toString();
			System.out.println("sessionid "+sessionid+" md5 version is "+hexString.toString());
			sessionid=hexString+"";
		}catch(NoSuchAlgorithmException nsae){
		            
		}

		return sessionid;
		
/*	    const char *str = [input UTF8String];
	    unsigned char result[CC_MD5_DIGEST_LENGTH];
	    CC_MD5(str, strlen(str), result);
	    
	    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
	        [ret appendFormat:@"%02x", result[i]];
	    }
	    
	    return ret;
	    */
	}
}