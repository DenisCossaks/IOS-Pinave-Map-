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
import com.montre.util.JsonParser;

public class ReviewActivity extends Activity {
	
	
	private ArrayList<ReviewInfo> 	arrReviews = new ArrayList<ReviewInfo>();
	
	
	// List view
	private TextView	 tvLocationList = null;
	private ListView	 listView = null;
	private ResultListAdapter 			adapter = null;
	private EditText	editText = null;
	
	final int	PROGRESS_DIALOG = 0;
	final int 	LOADING_OK	= 1;
	final int	LOADING_FAIL = 2;
	
	private String m_strPinId = "";
	
	
    /** Called when the activity is first created. */
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags( WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
						| WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
						| WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
		
        setContentView(R.layout.review);
        
        initView();
        initData();
        
    }
  
    public void initView()
    {
    	tvLocationList 	= (TextView) findViewById(R.id.review_location);
    	listView 	= (ListView) findViewById(R.id.review_list);
    	
    	editText = (EditText) findViewById(R.id.review_text);
    	Button btnSend = (Button) findViewById(R.id.review_send);
    	btnSend.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				
				String textSend = editText.getText().toString();
				if (textSend.length() > 0) {
					postReview(textSend);
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
    
    public void initData()
    {
    	arrReviews.clear();
    	
    	Intent intent = getIntent();
		m_strPinId = intent.getStringExtra("pinId");
		
		showDialog(PROGRESS_DIALOG);
    }

	protected Dialog onCreateDialog(int id) {
		switch (id) {
		case PROGRESS_DIALOG:
			ProgressDialog dialog = new ProgressDialog(this);
			dialog.setCancelable(false);
			dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
			dialog.setMessage("Loading...");
			
			new Thread(new Runnable() {
				
				public void run() {
					loadingProcess();
				}
			}).start();
			return dialog;
		}
		return super.onCreateDialog(id);
	}
	
	private void loadingProcess() {
		
		try {

			arrReviews.clear();
			
			arrReviews = JsonParser.getReviews(m_strPinId);
			

		} catch (Exception e) {
			// TODO: handle exception
			mHandler.sendEmptyMessage(LOADING_FAIL);
		}
		
		mHandler.sendEmptyMessage(LOADING_OK);
		
	}
	
	   Handler mHandler = new Handler() {

			@Override
			public void handleMessage(Message msg) {
				super.handleMessage(msg);

				dismissDialog(PROGRESS_DIALOG);
				
				switch (msg.what) {
				case LOADING_OK:
					
					setListView();
					
					break;
				case LOADING_FAIL:
					Const.showMessage("Error", "Json parse error", ReviewActivity.this);
					
					break;
				default:
					break;
				}
			}

		};
		
	public void postReview(String message) {
		 HttpClient httpclient = new DefaultHttpClient();
		 String url = Utils.postReviewsUrl();
		 HttpPost httppost = new HttpPost(url);

		 
		 String chat_code 	= Share.g_userInfo.str_chatcode;
		 String chat_id 	= Share.g_userInfo.str_chat_id;
		 String pinId = m_strPinId;
		 
		 try {
		 // Add your data
		 List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
		 nameValuePairs.add(new BasicNameValuePair("code", chat_code));
		 nameValuePairs.add(new BasicNameValuePair("message[message]", message));
		 nameValuePairs.add(new BasicNameValuePair("message[user_id]", chat_id));
		 nameValuePairs.add(new BasicNameValuePair("pin", pinId));
		 
		 httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));

		 // Execute HTTP Post Request
		 HttpResponse response = httpclient.execute(httppost);
		 String responseBody = EntityUtils.toString(response.getEntity());
		 
		 System.out.println("post review = " + responseBody);
		 
		 Const.showToastMessage("post review OK", this);
		 finish();
		 
		 } catch (Exception e) {
			 e.printStackTrace();
			 
			 Const.showMessage(ReviewActivity.this);
		 }
	}
	
	public void setListView () {
		
		tvLocationList.setText(Share.getStandardUserLocationAddress());
		boundAdapter();
		
	}
	
    public void boundAdapter() {
    	if (arrReviews == null) {
			return;
		}
    	
		adapter = new ResultListAdapter(ReviewActivity.this, arrReviews, listView);
		listView.setAdapter(adapter);
		adapter.notifyDataSetChanged();
	}
    
    
 	
    
	public class ResultListAdapter extends BaseAdapter {
		private Context mContext = null;
		private ArrayList<ReviewInfo> itemList = null;
		
		/**
		 * 
		 * @param mcontent
		 * @param itemList
		 */
		public ResultListAdapter(Context mContext, ArrayList<ReviewInfo> itemList,
				ListView listview) {
			this.mContext = mContext;
			this.itemList = itemList;
		}

		@Override
		public int getCount() {
			int index = itemList.size();
			return index;
		}

		@Override
		public Object getItem(int position) {
			return itemList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			int index = position;
			
			View view = convertView;
			ViewCache cache;
			{
				LayoutInflater inflater = LayoutInflater.from(mContext);
				view = inflater.inflate(R.layout.list_content_review, null);
				cache = new ViewCache(view);
				view.setTag(cache);
			}
			cache = (ViewCache) view.getTag();

			ReviewInfo item = itemList.get(index);
			if (item == null) 
				return view;
			
			
			TextView tvTitle = (TextView) view.findViewById(R.id.cell_title);
			tvTitle.setText(item.strUserName);
			
			TextView tvAddress = (TextView) view.findViewById(R.id.cell_address);
			tvAddress.setText(item.strDate);
			
			TextView tvDistance = (TextView) view.findViewById(R.id.cell_distance);
			tvDistance.setText(item.strMessage);

			return view;
		}

	}

	class ViewCache {
		private View view;
		private ImageView imageView = null;

		public ViewCache(View view) {
			this.view = view;
		}

		public ImageView getImageView() {
			if (imageView == null) {
				imageView = (ImageView) view
						.findViewById(R.id.cell_image);
			}
			return imageView;
		}
	}
	
}