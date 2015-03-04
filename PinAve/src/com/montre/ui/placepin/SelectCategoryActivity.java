package com.montre.ui.placepin;

import java.io.File;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;

import com.montre.data.CategoryInfo;
import com.montre.data.Items;
import com.montre.data.Share;
import com.montre.data.UserInfo;
import com.montre.data.UserLoginInfo;
import com.montre.lib.Const;
import com.montre.lib.UserDefault;
import com.montre.pinave.R;
import com.montre.pinave.login.HomeActivity;
import com.montre.ui.basic.BasicUI;
import com.montre.ui.explore.SearchActivity;
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
import android.graphics.Typeface;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.view.View.OnClickListener;


public class SelectCategoryActivity extends BasicUI {
    /** Called when the activity is first created. */
	
	
	private ListView lvCategory = null;
	private ResultListAdapter 	adapter = null;
	
	ArrayList<CategoryInfo> arrCategory = new ArrayList<CategoryInfo>();
	
	public int m_nSelect = -1;
	
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags( WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
						| WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
						| WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
		
		
        setContentView(R.layout.selectcategory);
        
        this.initViews();
        
    }
    
    
    public void onBackPressed() {
/*    	
		if ( locationManager != null ) {
			//locationManager.removeGpsStatusListener(this);
			locationManager.removeUpdates(netLocationListener);
			locationManager.removeUpdates(gpsLocationListener);
			netLocationListener = null;
			gpsLocationListener = null;
			locationManager = null;
		}
*/		
//		super.onBackPressed();
    	finish();
	}
    
    @Override
	public void initViews() {
		// TODO Auto-generated method stub
    	
    	Button btnBack = (Button) findViewById(R.id.btn_left);
    	btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onBackPressed();
			}
		});
    	
    	
    	lvCategory = (ListView) findViewById(R.id.lv_list);
    	
    	m_nSelect = ActivePinActivity.m_nCategoryId;
    	
    	arrCategory.clear();
    	for (int i = 0; i < Share.g_arrCategory.size(); i++) {
			CategoryInfo info = Share.g_arrCategory.get(i);
			
			if (!info.strId.equals("999")){
				arrCategory.add(info);
			}
		}
    	
    	boundAdapter(arrCategory);
	}


	@Override
	public void initData() {
		// TODO Auto-generated method stub
		
	}
     
    
    public void boundAdapter(ArrayList<CategoryInfo> list) {
		
    	adapter = new ResultListAdapter(SelectCategoryActivity.this, list, lvCategory);
		lvCategory.setAdapter(adapter);
		adapter.notifyDataSetChanged();
    }
    
    
    public class ResultListAdapter extends BaseAdapter {
		private Context mContext = null;
		private ArrayList<CategoryInfo> itemList = null;
		private ListView listView1;
		
		
		public ResultListAdapter(Context mContext, ArrayList<CategoryInfo> itemList,
				ListView listView1) {
			this.mContext = mContext;
			this.listView1 = listView1;
			this.itemList = itemList;
			
		}

		@Override
		public int getCount() {
			return itemList.size();
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
		public View getView(final int position, View convertView, ViewGroup parent) {
			View view = convertView;
			ViewCache cache;
			
			if (view == null) {
				LayoutInflater inflater = LayoutInflater.from(mContext);
				view = inflater.inflate(R.layout.list_content_category_check, null);
				cache = new ViewCache(view);
				view.setTag(cache);
			} else {
				cache = (ViewCache) view.getTag();
			}
			
			if(itemList == null || itemList.size()==0)
				return view;
							
			final CategoryInfo item = itemList.get(position);
			
			if(item == null)
				return view;
			
			ImageView ivCategory = (ImageView)view.findViewById(R.id.cell_category);
			TextView title = (TextView) view.findViewById(R.id.cell_title);
			ImageView ivArrow = (ImageView)view.findViewById(R.id.cell_arrow);
			
			ivCategory.setBackgroundResource(item.getResouceId());
			
			String text = item.getName();
			title.setText(text);
			
			if (item.getId().equals("" + m_nSelect)) {
				ivArrow.setVisibility(View.VISIBLE);
			} else {
				ivArrow.setVisibility(View.INVISIBLE);
			}
			
			view.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					gotoSelect(item);
				}
			});
			
    		
			return view;
			
		}


	}
 	class ViewCache {
		private View view;
//		private WebView iconWebView = null;

		public ViewCache(View view) {
			this.view = view;
		}

//		public WebView getWebView() {
//			if (iconWebView == null) {
//				iconWebView = (WebView) view
//						.findViewById(R.id.iconWebView);
//			}
//			return iconWebView;
//		}
	}
	
	
	
	private void gotoSelect(CategoryInfo selCategory)
	{
		ActivePinActivity.m_nCategoryId = Integer.parseInt(selCategory.getId());
		
		finish();
	}
}