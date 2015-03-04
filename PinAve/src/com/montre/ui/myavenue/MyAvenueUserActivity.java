package com.montre.ui.myavenue;


import java.io.File;
import java.util.ArrayList;
import java.util.Hashtable;

import com.montre.data.CategoryInfo;
import com.montre.data.PinInfo;
import com.montre.data.Setting;
import com.montre.data.Share;
import com.montre.data.UserInfo;
import com.montre.data.UserLoginInfo;
import com.montre.httpclient.AsyncImageLoader_Async;
import com.montre.lib.ComputeDistance;
import com.montre.lib.Const;
import com.montre.pinave.R;
import com.montre.pindetail.PinDetailActivity;
import com.montre.ui.basic.BasicUI;
import com.montre.ui.explore.ExploreActivity;
import com.montre.ui.explore.SearchActivity;
import com.montre.ui.explore.ExploreActivity.ResultListAdapter;
import com.montre.ui.myavenue.MyAvenueActivity.ViewCache;
import com.montre.util.JsonParser;

import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;


public class MyAvenueUserActivity extends BasicUI {

	private TextView tvHeader = null;
	private TextView tvLocation = null;
	private TextView tvTimezone = null;
	private TextView tvLastLogin = null;
	private ListView lvList = null;
	private ResultListAdapter 	adapter = null;
	
	public String strUserId = "";
	public UserInfo userInfo = null;	
	public ArrayList<PinInfo> arrPins = new ArrayList<PinInfo>();
	
	final int	PROGRESS_DIALOG = 0;
	final int 	LOADING_OK	= 1;
	final int	LOADING_FAIL = 2;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		this.setContentView(R.layout.friend);
		
		this.initViews();
		this.initData();
				
	}

	@Override
	public void initViews() {
		// TODO Auto-generated method stub
		
		tvHeader = (TextView) findViewById(R.id.title);
		tvLocation = (TextView) findViewById(R.id.location);
		tvTimezone = (TextView) findViewById(R.id.timezone);
		tvLastLogin = (TextView) findViewById(R.id.last_login);
		
		lvList = (ListView) findViewById(R.id.lv_list);
		
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
		
		strUserId = getIntent().getStringExtra("userId");
		
		showDialog(PROGRESS_DIALOG);
		
	}

	protected Dialog onCreateDialog(int id) {
		switch (id) {
		case PROGRESS_DIALOG:
			ProgressDialog dialog = new ProgressDialog(getParent());
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
			for (int i = 0; i < Share.g_arrUsers.size(); i++) {
				UserInfo info = Share.g_arrUsers.get(i);
				
				if (info.str_id.equalsIgnoreCase(strUserId)) {
					userInfo = new UserInfo();
					userInfo = info;
					break;
				}
			}
			
			arrPins = JsonParser.getUserPins(strUserId);
			
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
					Const.showMessage("Error", "Json parse error", MyAvenueUserActivity.this);
					
					break;
				default:
					break;
				}
			}

		};	
		
	private void setListView(){
		
		if (userInfo != null) {
			tvHeader.setText(userInfo.str_firstname + " " + userInfo.str_lastname);
			tvLocation.setText(userInfo.str_detail_country);
			tvTimezone.setText(userInfo.str_detail_timezone);
			tvLastLogin.setText(userInfo.str_last_activity);
		}
		
		if (arrPins != null) {
			boundAdapter(arrPins);
		}
	}
	
	public void gotoDetail(PinInfo info) {
		Intent intent = new Intent(MyAvenueUserActivity.this, PinDetailActivity.class);

		intent.putExtra("pininfo", info);
					
		startActivity(intent);
//		goNextHistory("PinDetailActivity", intent);
	}
		
    public void boundAdapter(ArrayList<PinInfo> list) {
		
    	adapter = new ResultListAdapter(MyAvenueUserActivity.this, list, lvList);
    	lvList.setAdapter(adapter);
		adapter.notifyDataSetChanged();
    }

    
    public class ResultListAdapter extends BaseAdapter {
    	
		private Context mContext = null;
		private ArrayList<PinInfo> itemList = null;
		

		/**
		 * 
		 * @param mcontent
		 * @param itemList
		 */
		public ResultListAdapter(Context mContext, ArrayList<PinInfo> itemList,
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
				view = inflater.inflate(R.layout.list_content_myavenue_pin, null);
				cache = new ViewCache(view);
				view.setTag(cache);
			}
			cache = (ViewCache) view.getTag();

			final PinInfo item = itemList.get(index);
			if (item == null) 
				return view;
			
			ImageView imageView = cache.getImageView();
			
			String category_id = item.str_category_id;
			CategoryInfo category = getCategoryInfo(category_id);
			imageView.setBackgroundResource(category.getResouceId());
			
			TextView tvTitle = (TextView) view.findViewById(R.id.cell_title);
			tvTitle.setText(item.str_title);
			
			TextView tvAddress = (TextView) view.findViewById(R.id.cell_address);
			tvAddress.setText(item.str_country + " " + item.str_state + " " + item.str_city + " Address: " + item.str_address);
			
			view.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					gotoDetail(item);
				}
			});
			
			
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
	
	private CategoryInfo getCategoryInfo(String category_id) {
		CategoryInfo info = null;
		for (int i = 0; i < Share.g_arrCategory.size(); i++) {
			info = Share.g_arrCategory.get(i);
			if (info.strId.equalsIgnoreCase(category_id)){
				return info;
			}
		}
		return info;
	}
	
}
