package com.montre.pindetail;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
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
import android.widget.ProgressBar;
import android.widget.RatingBar;
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
import com.montre.util.JsonParser;

public class GiveRatingActivity extends Activity {
	
	RatingBar rbRating = null;
	ProgressBar progress = null;
	
	String 	m_strPinId = "";
	
    /** Called when the activity is first created. */
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags( WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
						| WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
						| WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
		
        setContentView(R.layout.giverating);
        
        initView();
//        initData();
        
    }
  
    public void initView()
    {
    	m_strPinId = getIntent().getStringExtra("pin_id");
    	
    	
    	rbRating = (RatingBar) findViewById(R.id.ratingBar1);
    	progress = (ProgressBar) findViewById(R.id.progressBar1);
    	progress.setVisibility(View.GONE);
    	
    	Button btnBack = (Button) findViewById(R.id.btn_left);
    	btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onBackPressed();
			}
		});
    	
    	Button btnSend = (Button) findViewById(R.id.btn_right);
    	btnSend.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				
				giveRating();
			}
		});

    }
    
 	public void giveRating() {
 		progress.setVisibility(View.VISIBLE);
 		
 		int mRating = (int) rbRating.getRating();
 		
 		HttpClient client  = new DefaultHttpClient();
 		
 		String url = Utils.postRatingUrl(UserLoginInfo.getLoginCode(), m_strPinId, mRating);
 		
 		try {
 			HttpGet get = new HttpGet(url);
 	 		
 	 		HttpResponse response = client.execute(get);
 	 		HttpEntity resEntity = response.getEntity();
 	 		if (resEntity != null) {
 	 			String strResult = EntityUtils.toString(resEntity);
 	 			
 	 			System.out.println("get :" + strResult);
 	 			
 	 			JSONObject obj = new JSONObject(strResult);
 				
 				if (obj != null) {
 					String result = obj.optString("message");

 					if (result.equalsIgnoreCase("OK")) {
 						String strTitle = "";
 						String strMessage = "Your rating has been submitted\n Thank you.";
 						AlertDialog.Builder dialog = new AlertDialog.Builder(this);
 						dialog.setTitle(strTitle);
 						dialog.setMessage(strMessage);
 						dialog.setIcon(android.R.drawable.ic_dialog_info);
 						dialog.setPositiveButton("OK", new DialogInterface.OnClickListener() {
							
							@Override
							public void onClick(DialogInterface dialog, int which) {
								// TODO Auto-generated method stub
								finish();
							}
						});
 						dialog.show();
 						
 						
 						progress.setVisibility(View.GONE);
 						
 						return;
 					}
 				}
 	 		}
 		} catch (Exception e) {
			// TODO: handle exception
		}
 		
 		
 		Const.showMessage(this);
 		
 		progress.setVisibility(View.GONE);
		 
	}

	
	
}