package com.montre.pindetail;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONObject;
import org.xmlpull.v1.XmlPullParserException;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Canvas;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.SyncStateContract.Constants;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.webkit.WebView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.ItemizedOverlay;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.OverlayItem;
import com.montre.data.CategoryInfo;
import com.montre.data.Items;
import com.montre.data.PinInfo;
import com.montre.data.ReviewInfo;
import com.montre.data.Setting;
import com.montre.data.Share;
import com.montre.data.UserLoginInfo;
import com.montre.data.Utils;
import com.montre.httpclient.AsyncImageLoader_Async;
import com.montre.lib.ComputeDistance;
import com.montre.lib.Const;
import com.montre.pinave.R;
import com.montre.ui.basic.BasicUI;
import com.montre.util.JsonParser;

public class SendMessageActivity extends BasicUI {
	
	TextView tvName = null;
	EditText etMessage = null;
			
	
	PinInfo pinInfo = new PinInfo();
	
	
    /** Called when the activity is first created. */
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags( WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
						| WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
						| WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
		
        setContentView(R.layout.sendmessage);
        
        initViews();
//        initData();
        
    }
  
	@Override
	public void initViews() {
		// TODO Auto-generated method stub
	
		pinInfo = (PinInfo) getIntent().getSerializableExtra("pin_info");
    	
    	tvName 	= (TextView) findViewById(R.id.label_text);
    	String author = pinInfo.str_author;
    	if (author == null || author.indexOf("null") > -1) {
    		author = "";
    	}
    	tvName.setText(author);
    	
    	etMessage = (EditText) findViewById(R.id.edit_message);
    	etMessage.setText("Hello " + author + "!\n");
    	
    	Button btnSend = (Button) findViewById(R.id.btn_right);
    	btnSend.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				
				String textSend = etMessage.getText().toString();
				if (textSend.length() > 0) {
					sendMessage(textSend);
				}
				
				
			}
		});
    	
    	Button btnBack = (Button) findViewById(R.id.btn_left);
    	btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onBackPressed();
			}
		});
	}

	@Override
	public void initData() {
		// TODO Auto-generated method stub
		
	}
	
    
 		
	public void sendMessage(String message) {
		
		String pinId = pinInfo.str_id;
		String userId = pinInfo.str_user_id;
		
		if (pinId == null || pinId.length() < 1 || pinId.indexOf("null") > -1) {
			Const.showToastMessage("Pin id is fail", this);
			return;
		}
		if (userId == null || userId.length() < 1 || userId.indexOf("null") > -1) {
			Const.showToastMessage("User id is fail", this);
			return;
		}
		if (message.length() < 1) {
			Const.showToastMessage("Please input message", this);
			return;
		}

		
		 HttpClient httpclient = new DefaultHttpClient();
		 String url = Utils.postSendMessageUrl(UserLoginInfo.getLoginCode());
		 HttpPost httppost = new HttpPost(url);

		 
		 try {
		 // Add your data
		 List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
		 nameValuePairs.add(new BasicNameValuePair("pin", pinId));
		 nameValuePairs.add(new BasicNameValuePair("recepient", userId));
		 nameValuePairs.add(new BasicNameValuePair("message", message));
		 
		 httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));

		 // Execute HTTP Post Request
		 HttpResponse response = httpclient.execute(httppost);
		 String responseBody = EntityUtils.toString(response.getEntity());

		 System.out.println("post : send message = " + responseBody);

		 JSONObject obj = new JSONObject(responseBody);
		 if (obj != null) {
			String result = obj.optString("message");
			if (result.equalsIgnoreCase("OK")) {
				 Const.showToastMessage("Your message has been sent. Please expect a response by email", this);
				 return;
			}
		 }
		 
		 } catch (Exception e) {
			 e.printStackTrace();
		 }
		 
		 Const.showToastMessage("Fail", this);
		 
	}
}